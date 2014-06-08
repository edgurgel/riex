defmodule RiexTest do
  use Riex.Case
  import Riex.Helper

  test "put", context do
    pid = context[:pid]
    key = Riex.Helper.random_key

    o =  Riex.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")

    assert Riex.put(pid, o) == o
  end

  test "find", context do
    pid = context[:pid]
    key = Riex.Helper.random_key

    data = "Drew Kerrigan"
    o =  Riex.Object.create(bucket: "user", key: key, data: data)
    Riex.put(pid, o)

    assert Riex.find(pid, "user", key).data == o.data
  end

  test "delete", context do
    pid = context[:pid]
    key = Riex.Helper.random_key

    o =  Riex.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
    Riex.put(pid, o)

    assert Riex.delete(pid, o) == :ok
  end

  test "crud operations and siblings", context do
    pid = context[:pid]
    key = Riex.Helper.random_key

    o =  Riex.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
    u = Riex.put(pid, o)

    assert u != nil

    assert :ok == Riex.delete pid, "user", u.key

    u = Riex.Object.create(bucket: "user", data: "Drew Kerrigan")
    assert u.key == :undefined
    u = Riex.put pid, u
    assert u.key != :undefined

    # Get the object again so we don't create a sibling
    u = Riex.find pid, "user", u.key

    o = %{u | data: "Something Else"}
    u = Riex.put pid, o

    unewdata = Riex.find pid, "user", u.key

    if is_list(unewdata) and length(unewdata) == 2 do
      Riex.resolve pid, "user", u.key, index_of("Drew Kerrigan", unewdata)

      unewdata = Riex.find pid, "user", u.key

      unewdata
    end

    assert unewdata.data == "Something Else"

    assert :ok == Riex.delete pid, "user", u.key
    assert :ok == Riex.delete pid, "user", key

    assert nil == Riex.find pid, "user", key
  end

  test "user metadata", context do
    pid = context[:pid]
    key = Riex.Helper.random_key

    mdtest = Riex.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riex.Object.put_metadata({"my_key", "my_value"})
      |> Riex.Object.put_metadata({"my_key2", "my_value2"})

      mdtest = Riex.put(pid, mdtest)
        |> Riex.Object.get_metadata("my_key")

    assert mdtest == "my_value"

    u = Riex.find pid, "user", key

    mdtest2 = u
      |> Riex.Object.get_metadata("my_key2")

    assert mdtest2 == "my_value2"

    mdtest3 = u
      |> Riex.Object.get_all_metadata()
      |> is_list

    assert mdtest3

    u = Riex.Object.delete_metadata(u, "my_key")

    assert nil == Riex.Object.get_metadata(u, "my_key")
    assert "my_value2" == Riex.Object.get_metadata(u, "my_key2")

    u = Riex.Object.delete_all_metadata(u)

    assert nil == Riex.Object.get_metadata(u, "my_key2")
    assert [] == Riex.Object.get_all_metadata(u)
  end

  test "secondary indexes", context do
    pid = context[:pid]
    key = Riex.Helper.random_key

    o = Riex.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riex.Object.put_index({:binary_index, "first_name"}, ["Drew"])
      |> Riex.Object.put_index({:binary_index, "last_name"}, ["Kerrigan"])
    Riex.put(pid, o)

    assert Riex.Object.get_index(o, {:binary_index, "first_name"}) == ["Drew"]

    {keys, terms, continuation} = Riex.Index.query(pid, "user", {:binary_index, "first_name"}, "Drew", [])
    assert is_list(keys)
    assert terms == :undefined
    assert continuation == :undefined
    {keys, terms, continuation} = Riex.Index.query(pid, "user", {:binary_index, "last_name"}, "Kerrigam", "Kerrigao", [])
    assert is_list(keys)
    assert terms == :undefined
    assert continuation == :undefined

    o = Riex.Object.delete_index(o, {:binary_index, "first_name"})
    Riex.put(pid, o)

    assert Riex.Object.get_index(o, {:binary_index, "first_name"}) == nil

    assert is_list(Riex.Object.get_all_indexes(o))

    indextest = o |> Riex.Object.delete_all_indexes
      |> Riex.Object.get_all_indexes

    assert indextest == []
  end

  test "links", context do
    pid = context[:pid]

    o1 =Riex.Object.create(bucket: "user", key: "drew1", data: "Drew1 Kerrigan")
    Riex.put(pid, o1)
    o2 = Riex.Object.create(bucket: "user", key: "drew2", data: "Drew2 Kerrigan")
    Riex.put(pid, o2)

    key = Riex.Helper.random_key

    o = Riex.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")
      |> Riex.Object.put_link("my_tag", "user", "drew1")
      |> Riex.Object.put_link("my_tag", "user", "drew2")
    Riex.put(pid, o)

    assert Riex.Object.get_link(o, "my_tag") == [{"user", "drew1"}, {"user", "drew2"}]

    assert Riex.Object.delete_link(o, "my_tag") |> Riex.Object.get_link("my_tag") == nil

    # Get the object again so we don't create a sibling
    o = Riex.find pid, "user", key

    o |> Riex.Object.put_link("my_tag", "user", "drew1")
      |> Riex.Object.put_link("my_tag", "user", "drew2")
    Riex.put(pid, o)

    assert Riex.Object.get_link(o, "my_tag") == [{"user", "drew1"}, {"user", "drew2"}]

    assert is_list(Riex.Object.get_all_links(o))
    assert Riex.Object.delete_all_links(o) |> Riex.Object.get_all_links == []
  end

  test "ping", context do
    assert Riex.ping(context[:pid]) == :pong
  end

  test "siblings", context do
    pid = context[:pid]
    assert :ok == Riex.Bucket.put pid, "user", [{:allow_mult, true}]

    key = Riex.Helper.random_key

    o1 = Riex.Object.create(bucket: "user", key: key, data: "Drew1 Kerrigan")
    Riex.put(pid, o1)
    o2 = Riex.Object.create(bucket: "user", key: key, data: "Drew2 Kerrigan")
    Riex.put(pid, o2)

    u = Riex.find pid, "user", key

    assert is_list(u)

    [h|_t] = u

    assert :ok == Riex.resolve(pid, "user", key, 2)

    u = Riex.find pid, "user", key

    assert u.data == h

    assert :ok == Riex.Bucket.reset pid, "user"
  end
end
