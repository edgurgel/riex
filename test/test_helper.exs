ExUnit.start

defmodule Riex.Case do
  use ExUnit.CaseTemplate

  setup do
    {:ok, pid } = Riex.Connection.start('127.0.0.1', 8087)
    on_exit fn ->
      Riex.Helper.clean! pid
      Process.exit(pid, :kill)
    end
    {:ok, pid: pid}
  end
end

defmodule Riex.Helper do
  def clean!(pid) do
    for bucket <- Riex.Bucket.list!(pid), key <- Riex.Bucket.keys!(pid, bucket) do
      Riex.delete(pid, bucket, key)
    end
  end

  def random_key do
    {me, se, mi} = :erlang.now
    "#{me}#{se}#{mi}"
  end

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
end
