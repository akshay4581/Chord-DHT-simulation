defmodule ConsistentHasher do

  def compile_hasher do
    IO.puts "hashing.ex"
  end

  def string_SHA do
    Base.encode16(:crypto.hash(:sha, Utilities.randstr))
    # IO.puts "#{Base.encode16(:crypto.hash(:sha256, Utilities.randstr))}"
  end

  def get_ID(m) do
    # IO.puts "#{m}"
    str = __MODULE__.string_SHA
    # IO.puts "#{str}"
    String.to_integer(String.slice((str),0..m-1),16)
  end

end
