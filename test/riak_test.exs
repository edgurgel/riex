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
    {:ok, pid } = Riak.start_link('127.0.0.1', 8087)
    {:ok, pid: pid}
  end

  teardown context do
    pid = context[:pid]
    for bucket <- Riak.Bucket.list!(pid), key <- Riak.Bucket.keys!(pid, bucket) do
      Riak.delete(pid, bucket, key)
    end
    :ok
  end

  test "list bucket", context do
    {:ok, buckets} = Riak.Bucket.list context[:pid]
    assert is_list(buckets)
  end

  test "list keys", context do
    {:ok, users} = Riak.Bucket.keys context[:pid], "user"
    assert is_list(users)
  end

  test "bucket props", context do
    pid = context[:pid]
    # Currently there seems to be a bug that returns "Creating new atoms from protobuffs message!"
    assert :ok == Riak.Bucket.put pid, "user", [{:notfound_ok, false}]

    {:ok, props} = Riak.Bucket.get pid, "user"
    assert is_list(props)
    assert props[:notfound_ok] == false

    assert :ok == Riak.Bucket.reset pid, "user"

    {:ok, props} = Riak.Bucket.get pid, "user"
    assert props[:notfound_ok] == true
  end

  test "crud operations and siblings", context do
    pid = context[:pid]
    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"

    o =  Riak.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
    u = Riak.put(pid, o)

    assert u != nil

    assert :ok == Riak.delete pid, "user", u.key

    u = Riak.Object.create(bucket: "user", data: "Drew Kerrigan")
    assert u.key == :undefined
    u = Riak.put pid, u
    assert u.key != :undefined

    # Get the object again so we don't create a sibling
    u = Riak.find pid, "user", u.key

    o = %{u | data: "Something Else"}
    u = Riak.put pid, o

    unewdata = Riak.find pid, "user", u.key

    if is_list(unewdata) and length(unewdata) == 2 do
      Riak.resolve pid, "user", u.key, index_of("Drew Kerrigan", unewdata)

      unewdata = Riak.find pid, "user", u.key

      unewdata
    end

    assert unewdata.data == "Something Else"

    assert :ok == Riak.delete pid, "user", u.key
    assert :ok == Riak.delete pid, "user", key

    assert nil == Riak.find pid, "user", key
  end

  test "user metadata", context do
    pid = context[:pid]
    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"
    mdtest = Riak.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riak.Object.put_metadata({"my_key", "my_value"})
      |> Riak.Object.put_metadata({"my_key2", "my_value2"})

      mdtest = Riak.put(pid, mdtest)
        |> Riak.Object.get_metadata("my_key")

    assert mdtest == "my_value"

    u = Riak.find pid, "user", key

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

  test "secondary indexes", context do
    pid = context[:pid]
    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"
    o = Riak.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riak.Object.put_index({:binary_index, "first_name"}, ["Drew"])
      |> Riak.Object.put_index({:binary_index, "last_name"}, ["Kerrigan"])
    Riak.put(pid, o)

    assert Riak.Object.get_index(o, {:binary_index, "first_name"}) == ["Drew"]

    {keys, terms, continuation} = Riak.Index.query(pid, "user", {:binary_index, "first_name"}, "Drew", [])
    assert is_list(keys)
    assert terms == :undefined
    assert continuation == :undefined
    {keys, terms, continuation} = Riak.Index.query(pid, "user", {:binary_index, "last_name"}, "Kerrigam", "Kerrigao", [])
    assert is_list(keys)
    assert terms == :undefined
    assert continuation == :undefined

    o = Riak.Object.delete_index(o, {:binary_index, "first_name"})
    Riak.put(pid, o)

    assert Riak.Object.get_index(o, {:binary_index, "first_name"}) == nil

    assert is_list(Riak.Object.get_all_indexes(o))

    indextest = o |> Riak.Object.delete_all_indexes
      |> Riak.Object.get_all_indexes

    assert indextest == []
  end

  test "links", context do
    pid = context[:pid]

    o1 =Riak.Object.create(bucket: "user", key: "drew1", data: "Drew1 Kerrigan")
    Riak.put(pid, o1)
    o2 = Riak.Object.create(bucket: "user", key: "drew2", data: "Drew2 Kerrigan")
    Riak.put(pid, o2)

    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"
    o = Riak.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riak.Object.put_link("my_tag", "user", "drew1")
      |> Riak.Object.put_link("my_tag", "user", "drew2")
    Riak.put(pid, o)

    assert Riak.Object.get_link(o, "my_tag") == [{"user", "drew1"}, {"user", "drew2"}]

    assert Riak.Object.delete_link(o, "my_tag") |> Riak.Object.get_link("my_tag") == nil

    # Get the object again so we don't create a sibling
    o = Riak.find pid, "user", key

    o |> Riak.Object.put_link("my_tag", "user", "drew1")
      |> Riak.Object.put_link("my_tag", "user", "drew2")
    Riak.put(pid, o)

    assert Riak.Object.get_link(o, "my_tag") == [{"user", "drew1"}, {"user", "drew2"}]

    assert is_list(Riak.Object.get_all_links(o))
    assert Riak.Object.delete_all_links(o) |> Riak.Object.get_all_links == []
  end

  test "ping", context do
    assert Riak.ping(context[:pid]) == :pong
  end

  test "siblings", context do
    pid = context[:pid]
    assert :ok == Riak.Bucket.put pid, "user", [{:allow_mult, true}]

    {me, se, mi} = :erlang.now
    key = "#{me}#{se}#{mi}"

    o1 = Riak.Object.create(bucket: "user", key: key, data: "Drew1 Kerrigan")
    Riak.put(pid, o1)
    o2 = Riak.Object.create(bucket: "user", key: key, data: "Drew2 Kerrigan")
    Riak.put(pid, o2)

    u = Riak.find pid, "user", key

    assert is_list(u)

    [h|_t] = u

    assert :ok == Riak.resolve(pid, "user", key, 2)

    u = Riak.find pid, "user", key

    assert u.data == h

    assert :ok == Riak.Bucket.reset pid, "user"
  end

  test "counters", context do
    pid = context[:pid]
    {me, se, mi} = :erlang.now
    counter_key = "my_counter_#{me}#{se}#{mi}"

    assert :ok == Riak.Counter.enable(pid, "user")
    assert :ok == Riak.Counter.increment(pid, "user", counter_key, 1)
    assert :ok == Riak.Counter.increment(pid, "user", counter_key, 2)
    assert :ok == Riak.Counter.increment(pid, "user", counter_key, 3)

    assert 6 == Riak.Counter.value(pid, "user", counter_key)
  end
end
