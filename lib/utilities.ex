defmodule Utilities do

  def compile_utilities do
    IO.puts "utilities.ex"
  end

  # Generate random string
  # /----------------------------------------------/
  def randstr do
    randstr_([])
  end

  def randstr_(list) when length(list)<=32 do
    char = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            |> String.codepoints
            |> Enum.take_random(1)
            |> List.first
    randstr_([char|list])
  end

  def randstr_(list) when length(list)>32 do
    randStr = List.to_string(list)
    randStr
  end

  # Calculating m values
  # /----------------------------------------------/
  def calculate_m_forstr(numNodes) do
    temp = round(:math.ceil(:math.log2(numNodes)))
    # IO.puts "temp= #{temp}"
    m =
    if(temp/4 == 0) do
      1
    else
      round(:math.ceil(temp/4))
    end
    # IO.puts m
    m
  end

  def calculate_m(numNodes) do
    4*calculate_m_forstr(numNodes)
  end

  def create_node_IDs(numNodes,m) do
    node = ConsistentHasher.get_ID(m)
    create_list(numNodes,node,m,[])
  end

  def create_list(numNodes,node,m,list) when length(list) < numNodes do
    # IO.inspect list
    if(Enum.member?(list,node)) do
      # IO.puts "in true if"
      create_list(numNodes,ConsistentHasher.get_ID(m),m,list)
    else
      # IO.puts "in false if"
      new_node = ConsistentHasher.get_ID(m)
      list = list ++ [node]
      # IO.inspect list
      create_list(numNodes,new_node,m,list)
    end
  end

  def create_list(numNodes,node,m,list) when length(list) == numNodes do
    list
  end

  # generating finger tables and state related data
  # /----------------------------------------------/
  def get_table(node_ID,m,node_list) do
    # IO.puts "in get_table == #{node_ID}"
    size = round(:math.pow(2,m))
    (1..m)|>
    Enum.map(fn(i) ->
      get_entry(i,node_list,node_ID,size)
    end)
  end

  def get_entry(i,node_list, node_ID,size) do
    # IO.puts "in get_entry == #{node_ID}"
    start = round(node_ID + :math.pow(2,i-1))
    start_successor = get_successor(start,node_list,List.first(node_list))
    # IO.puts "start_successor == #{start_successor}"
    %{start: rem(start,size), start_successor: start_successor}
  end

  def get_successor(start,[], first) do
    first
  end

  def get_successor(start,node_list, first) do
    # IO.puts "in get_successor == #{start}"
    [head|tail] = node_list
    if(head >= start) do
      head
    else
      get_successor(start,tail, first)
    end
  end

  def get_predecessor(node,[],last) do
    last
  end

  def get_predecessor(node,node_list,last) do
    # IO.puts "in get_predecessor"
    [head|tail] = node_list
    if(head < node) do
      head
    else
      get_predecessor(node,tail,last)
    end
  end

  # Node functions
  # closest preceding finger
  # /----------------------------------------------/

  def closest_preceding_finger([], n, key,m) do
    n
  end

  def closest_preceding_finger(finger_table, n, key,m) do
    [head|tail] = finger_table
    finger_i_node = Map.get(head,:start_successor)
    return_finger =
    if(n > key) do
      if(zero_crossover(n,key,finger_i_node,m)) do
        finger_i_node
      else
        closest_preceding_finger(tail, n, key,m)
      end
    else
      if(no_zero_crossover(n,key,finger_i_node)) do
        finger_i_node
      else
        closest_preceding_finger(tail, n, key,m)
      end
    end
    return_finger
  end

  def zero_crossover(first,last,finger_i,m) do
    l = round(:math.pow(2,m))-1
    if((first..l)|> Enum.member?(finger_i) or (0..last)|> Enum.member?(finger_i)) do
      true
    else
      false
    end
  end

  def no_zero_crossover(first,last,finger_i) do
    if((first..last)|> Enum.member?(finger_i)) do
      true
    else
      false
    end
  end

  # starting requests
  # /----------------------------------------------/
  def start_requests(0,node_ID,finger_table,m,predecessor,numNodes,numRequests) do
    task_finished_by = :ets.update_counter(:time_table, "task_finished_by", {2,1})
    # IO.puts "all requests sent by #{node_ID}"
    total_hops = :ets.lookup_element(:time_table, "hop_count", 2)
    if(task_finished_by == numNodes) do
      # IO.puts "in system halt loop"
      total_requests = numNodes * numRequests
      avg_hops = total_hops/total_requests
      IO.puts "total_hops = #{total_hops}"
      IO.puts "avg hops = #{avg_hops}"
      :timer.sleep(1000)
      # if(avg_hops != 0)
      System.halt(1)
    end
  end

  def start_requests(rem_requests,node_ID,finger_table,m,predecessor,numNodes,numRequests) do
    # IO.puts "requests remaining = #{rem_requests}"
    key = Enum.random(0..round((:math.pow(2,m)-1)))
    # IO.puts "#{node_ID}requesting ----for ----key= #{key}"
    if(node_ID == key) do
      start_requests(rem_requests,node_ID,finger_table,m,predecessor,numNodes,numRequests)
    else
      # IO.puts "#{node_ID}requesting ----for ----key= #{key}"
      self_name = node_ID |> Integer.to_string() |> String.to_atom()
      GenServer.cast(self_name,{:find_id_successor,key,self_name})
       :timer.sleep(1000)
      start_requests(rem_requests-1,node_ID,finger_table,m,predecessor,numNodes,numRequests)
    end
  end

  def is_key_present_here(predecessor,node_ID,key,m) do
  if(predecessor+1 > node_ID) do
    if(zero_crossover(predecessor+1,node_ID,key,m)) do
      true
    else
      false
    end
  else
      if(no_zero_crossover(predecessor+1,node_ID,key)) do
        true
      else
        false
      end
    end
  end

end

