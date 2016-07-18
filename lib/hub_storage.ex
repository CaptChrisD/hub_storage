defmodule HubStorage do

  alias Nerves.Hub, as: Hub
	require Logger
  use GenServer

  def start(args) do
    result = GenServer.start __MODULE__, args, []
    Logger.debug "#{__MODULE__} start returns #{inspect result}"
    result
  end

  def start_link(args) do
    result = GenServer.start_link __MODULE__, args, []
    Logger.debug "#{__MODULE__} start_link returns #{inspect result}"
    result
  end

  def init(args) do
    path = Dict.get(args, :path, nil)
    values = Dict.get(args, :values, [])
    type = Dict.get(args, :type, "store_point")

    case path do
      nil -> :error
      path ->
        Logger.debug "#{__MODULE__} starting on path: #{inspect path}"
        #BUGBUG Assumes PersistentStorage has already been started
        data = PersistentStorage.get(pstore_point(path), ["@type": type])

        data = data++values

        #Setup the hub and manage the point
        Hub.put path, data
        Hub.master path
        {:ok, %{path: path}}
    end
  end

  defp sp_name(path) do
    Enum.join(binarify([:kv_store | path]), "_")
  end

  defp pstore_point(path) do
    String.to_atom sp_name(path)
  end

  def handle_call({:request, path, params, _}, _, state) do
    Logger.debug "#{__MODULE__} getting request at: #{inspect path}"
    # POSSIBLE BUGBUG: Does Hub protect against attacks (ie: to much data)?
    reply = Hub.update path, params
    {{_,_}, updated} = Hub.fetch(Dict.get(state, :path))
    PersistentStorage.put pstore_point(Dict.get(state, :path)), updated
    {:reply, reply, state}
  end

  def binarify([h|t]), do: List.flatten [binarify(h), binarify(t)]
  def binarify(a) when is_atom(a), do: Atom.to_string(a)
  def binarify(o), do: o
end
