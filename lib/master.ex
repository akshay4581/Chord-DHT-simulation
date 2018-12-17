defmodule Master do

  def main(numNodes, numRequests) do
    start_network(numNodes, numRequests)
  end

  def get_IDs_list(numNodes) do
    # IO.inspect Utilities.create_node_IDs(numNodes,[],Utilities.calculate_m(numNodes))
    Enum.sort(Utilities.create_node_IDs(numNodes,Utilities.calculate_m_forstr(numNodes)))
  end

  def start_network(numNodes, numRequests) do
    m = Utilities.calculate_m(numNodes)
    node_list = get_IDs_list(numNodes)
    # IO.inspect node_list
    node_list |> Enum.each(fn(node_ID) ->
      {:ok, pid} =
      GenServer.start(Node_module, %{node_ID: node_ID, node_list: node_list, finger_table: [], successor: nil, predecessor: nil, numRequests: numRequests, numNodes: numNodes, m: m, request_made_by: nil})
      try do
        Process.register(pid,node_ID |> Integer.to_string() |> String.to_atom())
      rescue
        _e in ArgumentError -> false
      end
    end)
    start_nodes(node_list)
  end

  def start_nodes(node_list) do
    time_table = :ets.new(:time_table, [:set, :public, :named_table])
    :ets.insert(time_table, {"hop_count",0})
    :ets.insert(time_table, {"task_finished_by",0})
    node_list|> Enum.each(fn(each) ->
      GenServer.cast(each |> Integer.to_string() |> String.to_atom(),{:start_requests})
      # GenServer.cast(List.first(node_list) |> Integer.to_string() |> String.to_atom(),{:start_requests})
      # :timer.sleep(1000)
    end)
    infinite_loop()
  end

  def infinite_loop() do
    infinite_loop()
  end

end
