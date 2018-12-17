# Proj3

**TODO: Add description**

## Installation

Group Members: 
---------------
Akshay Rechintala (UFID: 4581-6988)
Keerthi Gudur (UFID: 8241-4961)

The overall goal of this project is to implement Chord protocol of the peer-to-peer model and calculate the average hops made per request.

Instruction to run code:
------------------------
mix run lib/proj3.ex numNodes numRequests. This command is for Windows OS. 
Output displays the total hops and average hops per request.

Working:
------------------------
Each node checks if it has the key that it is looking for. If not, it checks its successor to see if the key is present with the successor. If either of these is not the case it checks its finger table for a node that is nearest to the key and forwards the request to this node and the process continues until the node that has the key is reached. Each time a request is forwarded to another node, the hop count is incremented.

Largest Problem solved:
-------------------------
nodes: 15000
requests: 200


If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `proj3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:proj3, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/proj3](https://hexdocs.pm/proj3).

