defmodule Node_module do
  use GenServer
  def start_link do
    GenServer.start_link(__MODULE__,%{})
  end

  def compile_Node do
    IO.puts "node.ex"
  end

  # init
  def init(state) do
    # IO.puts "in init @node = #{state.node_ID}"
    finger_table = Utilities.get_table(state.node_ID, state.m, state.node_list)
    # IO.inspect finger_table
    new_state = Map.put(state,:finger_table,finger_table)
    predecessor = Utilities.get_predecessor(state.node_ID, Enum.reverse(state.node_list),List.last(state.node_list))
    new_state = Map.put(new_state,:predecessor,predecessor)
    successor = Map.get(List.first(finger_table), :start_successor)
    new_state = Map.put(new_state,:successor,successor)
    {:ok,new_state}
  end

  # handle cast for starting to make requests
  def handle_cast({:start_requests},state) do
    # IO.puts "starting requests"
    spawn_link(Utilities, :start_requests, [state.numRequests,state.node_ID,state.finger_table,state.m,state.predecessor,state.numNodes,state.numRequests])
    {:noreply,state}
  end

  # node responding to other node's request to find an ID's successor
  def handle_cast({:find_id_successor,key,request_made_by},state) do

    #  this node checks whether the requested key is between its predecessor and itself(itself included)
    #   => that this node contains the key
    if(Utilities.is_key_present_here(state.predecessor,state.node_ID,key,state.m)) do
      # IO.puts "request made by #{request_made_by} reached destination = #{state.node_ID}"
    else
      if(state.node_ID > state.successor) do
        if(Utilities.zero_crossover(state.node_ID+1,state.successor,key,state.m)) do
          :ets.update_counter(:time_table, "hop_count", {2,1})
          dest_node = state.successor|> Integer.to_string() |> String.to_atom()
          GenServer.cast(dest_node, {:find_id_successor,key,request_made_by})
        else
          # otherwise check finger table, forward request to nearest neighbour
          :ets.update_counter(:time_table, "hop_count", {2,1})
          next_node_ID = Utilities.closest_preceding_finger(Enum.reverse(state.finger_table), state.node_ID, key,state.m)
          # IO.puts "--@ #{state.node_ID}''''''going to #{next_node_ID}"
          next_node_name = next_node_ID |> Integer.to_string() |> String.to_atom()
          GenServer.cast(next_node_name, {:find_id_successor,key,request_made_by})
        end
      else
        if(Utilities.no_zero_crossover(state.node_ID+1,state.successor,key)) do
          :ets.update_counter(:time_table, "hop_count", {2,1})
          dest_node = state.successor|> Integer.to_string() |> String.to_atom()
          GenServer.cast(dest_node, {:find_id_successor,key,request_made_by})
        else
          # otherwise check finger table, forward request to nearest neighbour
          :ets.update_counter(:time_table, "hop_count", {2,1})
          next_node_ID = Utilities.closest_preceding_finger(Enum.reverse(state.finger_table), state.node_ID, key,state.m)
          # IO.puts "--@ #{state.node_ID}''''''going to #{next_node_ID}"
          next_node_name = next_node_ID |> Integer.to_string() |> String.to_atom()
          GenServer.cast(next_node_name, {:find_id_successor,key,request_made_by})
        end
      end
    end
    {:noreply,state}
  end
end
