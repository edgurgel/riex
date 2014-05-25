defmodule Riak.Client do
  @moduledoc "Riak Client"

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
