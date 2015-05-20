defmodule BencodeTest do
  use ExUnit.Case

  import Bencode

  test "Decode integer" do
    assert {:ok, 42} === decode("i42e")
  end

  test "Decode negative integer" do
    assert {:ok, -42} === decode("i-42e")
  end

  test "Decode zero integer" do
    assert {:ok, 0} === decode("i0e")
  end

  test "Decode integer with faulty tail" do
    assert {:error, :trailing_data} === decode("i123etest")
  end

  test "Negative zero is not allowed (exception)" do
    assert {:badmatch, nil} === catch_error(decode!("i-0e"))
  end

  test "Chars in numbers is not allowed (exception)" do
    assert {:badmatch, nil} === catch_error(decode!("i1a2e"))
  end

  test "Decode string with faulty tail" do
    assert {:error, :trailing_data} === decode("4:spamtest")
  end

  test "Decode empty string" do
    assert {:ok, ""} === decode("0:")
  end

  test "Decode empty string with faulty tail" do
    assert {:error, :trailing_data} === decode("0:test")
  end

  test "Decode unicode string" do
    assert {:ok, "exposé"} === decode("6:exposé")
  end
  
  test "Decode invalid integer" do
    assert {:error, :invalid_format} === decode("i2")
  end
  
  test "Decode too short string" do
    assert {:error, :invalid_format} === decode("5:spam")
  end

  test "Decode bytes" do
    assert {:ok, <<123, 2, 5>>} == decode("3:" <> <<123, 2, 5>>)
  end

  test "Decode list with strings" do
    assert {:ok, ["ham", "spam"]} === decode("l3:ham4:spame")
  end

  test "Decode list with ints" do
    assert {:ok, [12, 45]} === decode("li12ei45ee")
  end

  test "Decode list with string and int" do
    assert {:ok, ["spam", 42]} === decode("l4:spami42ee")
  end

  test "Decode list with nested string and int" do
    assert {:ok, ["spam", 42, ["ham", 56, ["clam", 89]]]} === decode("l4:spami42el3:hami56el4:clami89eeee")
  end

  test "Decode map with int key values" do
    assert {:ok, %{1 => 2, 3 => 4}} === decode("di1ei2ei3ei4ee")
  end

  test "Decode map with mixed key values" do
    assert {:ok, %{"spam" => 1, 2 => "ham"}} === decode("d4:spami1ei2e3:hame")
  end

  test "Decode nested map" do
    assert {:ok, %{%{1 => 2} => %{"ab" => "cd"}}} === decode("ddi1ei2eed2:ab2:cdee")
  end

  test "Decode complex map structure" do
    assert {:ok, %{[1,2] => "woot", "spam" => 1, 2 => ["spam", 42, ["ham", 56, ["clam", 89]]]}} === decode("dli1ei2ee4:woot4:spami1ei2el4:spami42el3:hami56el4:clami89eeeee")
  end

  test "Decode complex list structure" do
    assert {:ok, [%{1 => 2, "ab" => "cd"}, %{1 => 2, "ab" => "cd"}]} === decode("ldi1ei2e2:ab2:cdedi1ei2e2:ab2:cdee")
  end
  
  test "Decode empty list" do
    assert {:ok, []} === decode("le")
  end
  
  test "Decode empty map" do
    assert {:ok, %{}} === decode("de")
  end
  
  test "Decode faulty list" do
    assert {:error, :invalid_format} === decode("li2e")
  end
  
  test "Decode faulty map" do
    assert {:error, :invalid_format} === decode("di2e")
  end
  
  test "Decode list with tail" do
    assert {:error, :trailing_data} === decode("lei")
  end
  
  test "Decode map with tail" do
    assert {:error, :trailing_data} === decode("dei")
  end

  test "encode integer" do
    assert "i42e" === encode!(42)
  end
  
  test "encode string" do
    assert "4:spam" === encode!("spam")
  end

  test "encode unicode string" do
    assert "6:exposé" === encode!("exposé")
  end
  
  test "encode atom" do
    assert "4:spam" === encode!(:spam)
  end
  
  test "encode bytes" do
    assert <<51, 58, 1, 2, 3>> == encode!(<<1,2,3>>)
  end
  
  test "encode list with string and int" do
    assert "l4:spami42ee" === encode!(["spam", 42])
  end
  
  test "encode map with mixed key values" do
    assert "di2e3:ham4:spami1ee" === encode!(%{"spam" => 1, 2 => "ham"})
  end
  
  test "encode complex map structure" do
    assert "di2el4:spami42el3:hami56el4:clami89eeeeli1ei2ee4:woot4:spami1ee" === encode!(%{[1,2] => "woot", "spam" => 1, 2 => ["spam", 42, ["ham", 56, ["clam", 89]]]})
  end
  
  test "encode complex list structure" do
    assert "ldi1ei2e2:ab2:cdedi1ei2e2:ab2:cdee" === encode!([%{1 => 2, "ab" => "cd"}, %{1 => 2, "ab" => "cd"}])
  end
  
  test "encode and decode complex map structure" do
    data = [%{1 => 2, "ab" => "cd"}, %{1 => 2, "ab" => "cd"}]
    assert data == data |> encode! |> decode!
  end
  
  test "encode and decode list structure" do
    data = %{[1,2] => "woot", "spam" => 1, 2 => ["spam", 42, ["ham", 56, ["clam", 89]]]}
    assert data == data |> encode! |> decode!
  end
  
  test "encode with :ok tuple" do
    assert {:ok, "ldi1ei2e2:ab2:cdedi1ei2e2:ab2:cdee"} === encode([%{1 => 2, "ab" => "cd"}, %{1 => 2, "ab" => "cd"}])
  end
  
  test "encode invalid input with :error tuple" do
    assert {:error, :invalid_format} === Bencode.encode(2.0)
  end
  
  test "encode invalid input with exception" do
    assert_raise(ArgumentError, fn -> Bencode.encode!(2.0) end)
  end
end
