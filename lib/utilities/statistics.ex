defmodule Utilities.Statistics do
  use GenServer

  def init(opts) do
    :ets.new(:statistics, [:set, :public, :named_table])
    {:ok, opts}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def insert(genertion, statistics) do
    :ets.insert(:statistics, {genertion, statistics})
  end

  def lookup(genertion) do
    hd(:ets.lookup(:statistics, genertion))
  end
end
