defmodule BencodeTest do
  use ExUnit.Case

  import Bencode

  test "Decode integer" do
    assert decode!("i42e") === 42
  end

  test "Decode negative integer" do
    assert decode!("i-42e") === -42
  end

  test "Decode zero integer" do
    assert decode!("i0e") === 0
  end

  test "Decode integer with faulty tail" do
    assert decode("i123etest") === {:error, "test"}
  end

  test "Negative zero is not allowed" do
    assert catch_error(decode!("i-0e")) === {:badmatch, nil}
  end

  test "Chars in numbers is not allowed" do
    assert catch_error(decode!("i1a2e")) === {:badmatch, nil}
  end

  test "Decode string with faulty tail" do
    assert decode("4:spamtest") === {:error, "test"}
  end

  test "Decode empty string" do
    assert decode!("0:") === ""
  end

  test "Decode empty string with faulty tail" do
    assert decode("0:test") === {:error, "test"}
  end

  test "Decode bytes" do
    assert <<123, 2, 5>> == decode!("3:" <> <<123, 2, 5>>)
  end

  test "Decode list with strings" do
    assert ["ham", "spam"] === decode!("l3:ham4:spame")
  end

  test "Decode list with ints" do
    assert [12, 45] === decode!("li12ei45ee")
  end

  test "Decode list with string and int" do
    assert ["spam", 42] === decode!("l4:spami42ee")
  end

  test "Decode list with nested string and int" do
    assert ["spam", 42, ["ham", 56, ["clam", 89]]] === decode!("l4:spami42el3:hami56el4:clami89eeee")
  end

  test "Decode map with int key values" do
    assert %{1 => 2, 3 => 4} === decode!("di1ei2ei3ei4ee")
  end

  test "Decode map with mixed key values" do
    assert %{"spam" => 1, 2 => "ham"} === decode!("d4:spami1ei2e3:hame")
  end

  test "Decode nested map" do
    assert %{%{1 => 2} => %{"ab" => "cd"}} === decode!("ddi1ei2eed2:ab2:cdee")
  end

  test "Decode complex map structure" do
    assert %{[1,2] => "woot", "spam" => 1, 2 => ["spam", 42, ["ham", 56, ["clam", 89]]]} === decode!("dli1ei2ee4:woot4:spami1ei2el4:spami42el3:hami56el4:clami89eeeee")
  end

  test "Decode complex list structure" do
    assert [%{1 => 2, "ab" => "cd"}, %{1 => 2, "ab" => "cd"}] === decode!("ldi1ei2e2:ab2:cdedi1ei2e2:ab2:cdee")
  end
  
  test "Encode integer" do
    assert "i42e" === encode(42)
  end
  
  test "Encode string" do
    assert "4:spam" === encode("spam")
  end
  
  test "Encode bytes" do
    assert <<51, 58, 1, 2, 3>> == encode(<<1,2,3>>)
  end
  
  test "Encode list with string and int" do
    assert "l4:spami42ee" === encode(["spam", 42])
  end
  
  test "Encode map with mixed key values" do
    assert "di2e3:ham4:spami1ee" === encode(%{"spam" => 1, 2 => "ham"})
  end
  
  test "Encode complex map structure" do
    assert "di2el4:spami42el3:hami56el4:clami89eeeeli1ei2ee4:woot4:spami1ee" === encode(%{[1,2] => "woot", "spam" => 1, 2 => ["spam", 42, ["ham", 56, ["clam", 89]]]})
  end
  
  test "Encode complex list structure" do
    assert "ldi1ei2e2:ab2:cdedi1ei2e2:ab2:cdee" === encode([%{1 => 2, "ab" => "cd"}, %{1 => 2, "ab" => "cd"}])
  end
  
  test "Encode and decode complex map structure" do
    data = [%{1 => 2, "ab" => "cd"}, %{1 => 2, "ab" => "cd"}]
    assert data == data |> encode |> decode!
  end
  
  test "Encode and decode list structure" do
    data = %{[1,2] => "woot", "spam" => 1, 2 => ["spam", 42, ["ham", 56, ["clam", 89]]]}
    assert data == data |> encode |> decode!
  end
end
