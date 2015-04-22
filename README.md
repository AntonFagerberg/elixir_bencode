Elixir Bencode
==============

Bencode decoder / encoder using Elixir data structures.

[Documentation for Elixir Bencode is available online](http://hexdocs.pm/elixir_bencode/)

## Installation
Add it to to your `mix.exs` dependencies:

```elixir
defp deps do
  [{:elixir_bencode, "~> 1.0.0"}]
end
```

## Examples
```elixir
## Encode strings (with thrown exceptions)
Bencode.encode!("hello world")
"11:hello world"

## Encode integers
Bencode.encode!(42)
"i42e"

## Encode lists
Bencode.encode!([1,2,3])
"li1ei2ei3ee"

## Encode maps
Bencode.encode!(%{"a" => 1, 2 => "b"})
#"di2e1:b1:ai1ee"

## Encode Dicts
Bencode.encode!(HashDict.new |> Dict.put :hello, :world)
"d5:hello5:worlde"

## Encode bitstrings
Bencode.encode!(<<1,2,3,4>>)
<<52, 58, 1, 2, 3, 4>>

## Encode without exceptions
Bencode.encode(2.0)
{:error, :invalid_format}

## Decode strings (with thrown expcetions)
Bencode.decode!("5:hello")
"hello"

## Decode integers
Bencode.decode!("i42e")
42

## Decode lists 
Bencode.decode!("li1ei2ei3ee")
[1, 2, 3]

## Decode maps
Bencode.decode!("d5:hello5:worlde")
%{"hello" => "world"}

## Decode without exceptions
Bencode.decode("4:spam")
{:ok, "spam"}
```

## Copyright

Copyright (c) 2014 Anton Fagerberg. See [LICENSE](LICENSE) for further details
