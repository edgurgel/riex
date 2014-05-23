defmodule Riak.Client do
  @moduledoc """
  Riak Client
  """
  use GenServer.Behaviour

  defmodule State do
    defstruct socket_pid: nil
  end

  def start_link do
    :gen_server.start_link({ :local, :riak }, __MODULE__, nil, [])
  end

  def init do
    { :ok, nil }
  end

  def configure(opts) do
    :gen_server.call(:riak, {:configure, Keyword.fetch!(opts, :host), Keyword.fetch!(opts, :port)})
  end

  @doc "Ping a Riak instance"
  def ping, do: :gen_server.call(:riak, {:ping})

  def put(obj), do: :gen_server.call(:riak, {:store, obj})

  def find(bucket, key), do: :gen_server.call(:riak, {:fetch, bucket, key})

  def resolve(bucket, key, index) do
    :gen_server.call(:riak, {:resolve, bucket, key, index})
  end

  @doc "Delete an object from a bucket"
  def delete(bucket, key), do: :gen_server.call(:riak, {:delete, bucket, key})
  def delete(obj), do: :gen_server.call(:riak, {:delete, obj.bucket, obj.key})

  # Riak modules and functions

  def build_sibling_list([{_md, val}|t], final_list), do: build_sibling_list(t,[val|final_list])
  def build_sibling_list([], final_list), do: final_list


  # Start Link to Riak
  def handle_call({ :configure, host, port }, _from, _state) do
    {:ok, pid} = :riakc_pb_socket.start_link(host, port)
    new_state = %State{socket_pid: pid}
    { :reply, {:ok, pid}, new_state }
  end

  # Ping Riak
  def handle_call({ :ping }, _from, state) do
      { :reply, :riakc_pb_socket.ping(state.socket_pid), state }
  end

  # Store a Riak Object
  def handle_call({:store, obj }, _from, state) do
    case :riakc_pb_socket.put(state.socket_pid, obj.to_robj) do
      {:ok, new_object} ->
        { :reply, obj.key(:riakc_obj.key(new_object)), state }
      :ok ->
        { :reply, obj, state }
      _ ->
        { :reply, nil, state }
    end
  end

  # Fetch a Riak Object
  def handle_call({:fetch, bucket, key }, _from, state) do
    case :riakc_pb_socket.get(state.socket_pid, bucket, key) do
      {:ok, object} ->
        if :riakc_obj.value_count(object) > 1 do
          { :reply, build_sibling_list(:riakc_obj.get_contents(object),[]), state }
        else
          { :reply, RObj.from_robj(object), state }
        end
      _ -> { :reply, nil, state }
    end
  end

  # Resolve a Riak Object
  def handle_call({:resolve, bucket, key, index }, _from, state) do
    case :riakc_pb_socket.get(state.socket_pid, bucket, key) do
      {:ok, object} ->
        new_object = :riakc_obj.select_sibling(index, object)
        { :reply, :riakc_pb_socket.put(state.socket_pid, new_object), state }
      _ -> { :reply, nil, state }
    end
  end

  # Delete a Riak Object
  def handle_call({:delete, bucket, key }, _from, state) do
    { :reply, :riakc_pb_socket.delete(state.socket_pid, bucket, key), state }
  end

  def handle_call({:list_buckets, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.list_buckets(state.socket_pid, timeout), state}
  end

  def handle_call({:list_buckets}, _from, state) do
    { :reply, :riakc_pb_socket.list_buckets(state.socket_pid), state}
  end

  def handle_call({:list_keys, bucket, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.list_keys(state.socket_pid, bucket, timeout), state}
  end

  def handle_call({:list_keys, bucket}, _from, state) do
    { :reply, :riakc_pb_socket.list_keys(state.socket_pid, bucket), state}
  end

  def handle_call({:props, bucket}, _from, state) do
    { :reply, :riakc_pb_socket.get_bucket(state.socket_pid, bucket), state}
  end

  def handle_call({:set_props, bucket, props}, _from, state) do
    { :reply, :riakc_pb_socket.set_bucket(state.socket_pid, bucket, props), state}
  end

  def handle_call({:set_props, bucket, type, props}, _from, state) do
    { :reply, :riakc_pb_socket.set_bucket(state.socket_pid, {type, bucket}, props), state}
  end

  def handle_call({:reset, bucket}, _from, state) do
    { :reply, :riakc_pb_socket.reset_bucket(state.socket_pid, bucket), state}
  end

  def handle_call({:get_type, type}, _from, state) do
    { :reply, :riakc_pb_socket.get_bucket_type(state.socket_pid, type), state}
  end

  def handle_call({:set_type, type, props}, _from, state) do
    { :reply, :riakc_pb_socket.set_bucket_type(state.socket_pid, type, props), state}
  end

  def handle_call({:reset_type, type}, _from, state) do
    { :reply, :riakc_pb_socket.reset_bucket_type(state.socket_pid, type), state}
  end

  def handle_call({:mapred_query, inputs, query}, _from, state) do
    { :reply, :riakc_pb_socket.mapred(state.socket_pid, inputs, query), state}
  end

  def handle_call({:mapred_query, inputs, query, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.mapred(state.socket_pid, inputs, query, timeout), state}
  end

  def handle_call({:mapred_query_bucket, bucket, query}, _from, state) do
    { :reply, :riakc_pb_socket.mapred_bucket(state.socket_pid, bucket, query), state}
  end

  def handle_call({:mapred_query_bucket, bucket, query, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.mapred_bucket(state.socket_pid, bucket, query, timeout), state}
  end

  def handle_call({:index_eq_query, bucket, {type, name}, key, opts}, _from, state) do
    {:ok, name} = List.from_char_data(name)
    { :reply, :riakc_pb_socket.get_index_eq(state.socket_pid, bucket, {type, name}, key, opts), state}
  end

  def handle_call({:index_range_query, bucket, {type, name}, startkey, endkey, opts}, _from, state) do
    {:ok, name} = List.from_char_data(name)
    { :reply, :riakc_pb_socket.get_index_range(state.socket_pid, bucket, {type, name}, startkey, endkey, opts), state}
  end

  def handle_call({:search_list_indexes}, _from, state) do
    { :reply, :riakc_pb_socket.list_search_indexes(state.socket_pid), state}
  end

  def handle_call({:search_create_index, index}, _from, state) do
    { :reply, :riakc_pb_socket.create_search_index(state.socket_pid, index), state}
  end

  def handle_call({:search_get_index, index}, _from, state) do
    { :reply, :riakc_pb_socket.get_search_index(state.socket_pid, index), state}
  end

  def handle_call({:search_delete_index, index}, _from, state) do
    { :reply, :riakc_pb_socket.delete_search_index(state.socket_pid, index), state}
  end

  def handle_call({:search_get_schema, name}, _from, state) do
    { :reply, :riakc_pb_socket.get_search_schema(state.socket_pid, name), state}
  end

  def handle_call({:search_create_schema, name, content}, _from, state) do
    { :reply, :riakc_pb_socket.create_search_schema(state.socket_pid, name, content), state}
  end

  def handle_call({:search_query, index, query, options}, _from, state) do
    { :reply, :riakc_pb_socket.search(state.socket_pid, index, query, options), state}
  end

  def handle_call({:search_query, index, query, options, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.search(state.socket_pid, index, query, options, timeout), state}
  end

  def handle_call({:counter_incr, bucket, key, amount}, _from, state) do
    { :reply, :riakc_pb_socket.counter_incr(state.socket_pid, bucket, key, amount), state}
  end

  def handle_call({:counter_val, bucket, key}, _from, state) do
    { :reply, :riakc_pb_socket.counter_val(state.socket_pid, bucket, key), state}
  end
end
