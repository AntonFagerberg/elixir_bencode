Elixir Bencode
==============

Bencode (encode and decode) implemented in Elixir.

```elixir
Bencode.encode("hello world")
"11:hello world"

Bencode.encode(42)
"i42e"

Bencode.encode([1,2,3])
"li1ei2ei3ee"

Bencode.encode(%{"a" => 1, 2 => "b"})
"di2e1:b1:ai1ee"

Bencode.encode(HashDict.new |> Dict.put :hello, :world)
"d5:hello5:worlde"

Bencode.encode(<<1,2,3,4>>)
<<52, 58, 1, 2, 3, 4>>

Bencode.decode!("li1ei2ei3ee")
[1, 2, 3]

Bencode.decode!("i42e") # With exceptions
42

Bencode.decode("4:spam")  # Without exceptions
{:ok, "spam"}

Bencode.decode!("li1ei2ei3ee")
[1, 2, 3]

Bencode.decode!("d5:hello5:worlde")
%{"hello" => "world"}
```
