defmodule RiakTest do
  use ExUnit.Case

  # helper for chosing the index of a sibling value list
  def index_of(search, [search|_], index) do
    index
  end
  def index_of(search, [_|rest], index) do
    index_of(search, rest, index+1)
  end
  def index_of(search, haystack) do
    index_of(search, haystack, 1)
  end

  setup do
    Riak.configure(host: '127.0.0.1', port: 8087)
    :ok
  end

  test "list bucket" do
    {:ok, buckets} = Riak.Bucket.list
    assert is_list(buckets)
  end

  test "list keys" do
    {:ok, users} = Riak.Bucket.keys "user"
    assert is_list(users)
  end

  test "bucket props" do
    # Currently there seems to be a bug that returns "Creating new atoms from protobuffs message!"
    assert :ok == Riak.Bucket.put "user", [{:notfound_ok, false}]

    {:ok, props} = Riak.Bucket.get "user"
    assert is_list(props)
    assert props[:notfound_ok] == false

    assert :ok == Riak.Bucket.reset "user"

    {:ok, props} = Riak.Bucket.get "user"
    assert props[:notfound_ok] == true
  end

  test "crud operations and siblings" do
    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"

    u = Riak.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riak.put

    assert u != nil

    assert :ok == Riak.delete "user", u.key

    u = Riak.Object.create(bucket: "user", data: "Drew Kerrigan")
    assert u.key == :undefined
    u = Riak.put u
    assert u.key != :undefined

    # Get the object again so we don't create a sibling
    u = Riak.find "user", u.key

    u = %{u | data: "Something Else"}
      |> Riak.put

    unewdata = Riak.find "user", u.key

    if is_list(unewdata) and length(unewdata) == 2 do
      Riak.resolve "user", u.key, index_of("Drew Kerrigan", unewdata)

      unewdata = Riak.find "user", u.key

      unewdata
    end

    assert unewdata.data == "Something Else"

    assert :ok == Riak.delete "user", u.key
    assert :ok == Riak.delete "user", key

    assert nil == Riak.find "user", key
  end

  test "user metadata" do
    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"
    mdtest = Riak.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riak.Object.put_metadata({"my_key", "my_value"})
      |> Riak.Object.put_metadata({"my_key2", "my_value2"})
      |> Riak.put
      |> Riak.Object.get_metadata("my_key")

    assert mdtest == "my_value"

    u = Riak.find "user", key

    mdtest2 = u
      |> Riak.Object.get_metadata("my_key2")

    assert mdtest2 == "my_value2"

    mdtest3 = u
      |> Riak.Object.get_all_metadata()
      |> is_list

    assert mdtest3

    u = Riak.Object.delete_metadata(u, "my_key")

    assert nil == Riak.Object.get_metadata(u, "my_key")
    assert "my_value2" == Riak.Object.get_metadata(u, "my_key2")

    u = Riak.Object.delete_all_metadata(u)

    assert nil == Riak.Object.get_metadata(u, "my_key2")
    assert [] == Riak.Object.get_all_metadata(u)
  end

  test "secondary indexes" do
    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"
    u = Riak.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riak.Object.put_index({:binary_index, "first_name"}, ["Drew"])
      |> Riak.Object.put_index({:binary_index, "last_name"}, ["Kerrigan"])
      |> Riak.put

    assert Riak.Object.get_index(u, {:binary_index, "first_name"}) == ["Drew"]

    {keys, terms, continuation} = Riak.Index.query("user", {:binary_index, "first_name"}, "Drew", [])
    assert is_list(keys)
    assert terms == :undefined
    assert continuation == :undefined
    {keys, terms, continuation} = Riak.Index.query("user", {:binary_index, "last_name"}, "Kerrigam", "Kerrigao", [])
    assert is_list(keys)
    assert terms == :undefined
    assert continuation == :undefined

    u = Riak.Object.delete_index(u, {:binary_index, "first_name"})
      |> Riak.put

    assert Riak.Object.get_index(u, {:binary_index, "first_name"}) == nil

    assert is_list(Riak.Object.get_all_indexes(u))

    indextest = u |> Riak.Object.delete_all_indexes()
      |> Riak.Object.get_all_indexes()

    assert indextest == []
  end

  test "links" do
    Riak.Object.create(bucket: "user", key: "drew1", data: "Drew1 Kerrigan")
      |> Riak.put
    Riak.Object.create(bucket: "user", key: "drew2", data: "Drew2 Kerrigan")
      |> Riak.put

    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"
    u = Riak.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riak.Object.put_link("my_tag", "user", "drew1")
      |> Riak.Object.put_link("my_tag", "user", "drew2")
      |> Riak.put

    assert Riak.Object.get_link(u, "my_tag") == [{"user", "drew1"}, {"user", "drew2"}]

    assert Riak.Object.delete_link(u, "my_tag") |> Riak.Object.get_link("my_tag") == nil

    # Get the object again so we don't create a sibling
    u = Riak.find "user", key

    u   |> Riak.Object.put_link("my_tag", "user", "drew1")
      |> Riak.Object.put_link("my_tag", "user", "drew2")
      |> Riak.put

    assert Riak.Object.get_link(u, "my_tag") == [{"user", "drew1"}, {"user", "drew2"}]

    assert is_list(Riak.Object.get_all_links(u))
    assert Riak.Object.delete_all_links(u) |> Riak.Object.get_all_links() == []
  end

  test "ping" do
    assert Riak.ping == :pong
  end

  test "siblings" do
    assert :ok == Riak.Bucket.put "user", [{:allow_mult, true}]

    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"

    Riak.Object.create(bucket: "user", key: key, data: "Drew1 Kerrigan")
      |> Riak.put
    Riak.Object.create(bucket: "user", key: key, data: "Drew2 Kerrigan")
      |> Riak.put

    u = Riak.find "user", key

    assert is_list(u)

    [h|_t] = u

    assert :ok == Riak.resolve("user", key, 2)

    u = Riak.find "user", key

    assert u.data == h

    assert :ok == Riak.Bucket.reset "user"
  end

  test "counters" do
    {me, se, mi} = :erlang.now
    counter_key = "my_counter_#{me}#{se}#{mi}"

    assert :ok == Riak.Counter.enable("user")
    assert :ok == Riak.Counter.increment("user", counter_key, 1)
    assert :ok == Riak.Counter.increment("user", counter_key, 2)
    assert :ok == Riak.Counter.increment("user", counter_key, 3)

    assert 6 == Riak.Counter.value("user", counter_key)
  end
end
