defmodule Riak do
  @moduledoc """
  A Client for Riak.

  ## Setup
  The `start` function starts the OTP application, and `configure`
  sends a message to the OTP server running locally which starts
  the protobuf link with your Riak cluster.

      iex> Riak.start
      iex> Riak.configure(host: '127.0.0.1', port: 8087)

  The client supports secondary indexes. Remember to use a storage
  backend that support secondary indexes (such as *leveldb*), in
  your Riak configuration.

  ## Basic CRUD operations
  Data is inserted into the database using the `put` function. The
  inserted data needs to be an `RObj` created like this:

      iex> u = RObj.create(bucket: "user", key: "my_key", data: "Drew Kerrigan")
      iex> Riak.put u

  To get a data entry out of the database, use the `find` function.

      iex> u = Riak.find "user", "my_key"

  Updating data is done with by fetching a data entry, updating its
  data and putting it back into the database using `find` and `put`.

      iex> u = Riak.find "user", "my_key"
      iex> u = u.data("Updated Data")
      iex> Riak.put u

  Deleting data from the database is done using the `delete` function.

      iex> Riak.delete "user", "my_key"

  The client support secondary indexes, links and siblings. This is
  work in progress, and any help is greatly appreciated. Fork the code
  on [github](https://github.com/drewkerrigan/riak-elixir-client).
  """

  def start_link(host, port) do
    :riakc_pb_socket.start_link(host, port)
  end

  def ping(pid), do: :riakc_pb_socket.ping(pid)

  def put(pid, obj) do
    case :riakc_pb_socket.put(pid, Riak.Object.to_robj(obj)) do
      {:ok, new_object} -> %{obj | key: :riakc_obj.key(new_object)}
      :ok -> obj
      _ -> nil
    end
  end

  def find(pid, bucket, key) do
    case :riakc_pb_socket.get(pid, bucket, key) do
      {:ok, object} ->
        if :riakc_obj.value_count(object) > 1 do
          build_sibling_list(:riakc_obj.get_contents(object),[])
        else
          Riak.Object.from_robj(object)
        end
      _ -> nil
    end
  end

  defp build_sibling_list([{_md, val}|t], final_list), do: build_sibling_list(t,[val|final_list])
  defp build_sibling_list([], final_list), do: final_list

  def resolve(pid, bucket, key, index) do
    case :riakc_pb_socket.get(pid, bucket, key) do
      {:ok, object} ->
        new_object = :riakc_obj.select_sibling(index, object)
        :riakc_pb_socket.put(pid, new_object)
      _ -> nil
    end
  end

  def delete(pid, bucket, key), do: :riakc_pb_socket.delete(pid, bucket, key)
  def delete(pid, obj), do: delete(pid, obj.bucket, obj.key)
end
