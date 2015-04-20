defmodule Bencode do
  @moduledoc """
  Bencode decoder / encoder using Elixir data structures.

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
  """
  
  @type encodable :: binary | atom | Map | Dict.t | List | Integer
  @type error_trailing_data :: {:error, :trailing_data}
  @type error_invalid_format :: {:error, :invalid_format}
  @type bencode_error :: error_trailing_data | error_invalid_format
  
  @doc """
  Decode a Bencode bitstring to an Elixir data structure.
  
  An exception will be thrown if an invalid Bencoded string is provided.
  
  Args:
    * `bitstring` - Bencoded bitstring to decode.
  """
  @spec decode!(binary) :: encodable
  def decode!(bitstring) do
    case decode_p(bitstring) do
      {result, ""} -> result
      _ -> raise("Unparsed trailing data.")
    end
  end

  @doc """
  Decode a Bencode bitstring to an Elixir data structure.
  
  The function returns either `{:ok, data_structure}` on success, or
  `{:error, :trailing_data}` on unspecified trailing data or 
  `{:error, :invalid_format}` on format errors.
  
  Args:
    * `bitstring` - Bencoded bitstring to decode.
  """
  @spec decode(binary) :: {:ok, encodable} | bencode_error
  def decode(bitstring) do
    try do
      case decode_p(bitstring) do
        {result, ""} -> {:ok, result}
        _ -> {:error, :trailing_data}
      end
    rescue
      _ -> {:error, :invalid_format}
    end
  end

  defp decode_p("l" <> rest), do: decode_p(rest, [])
  defp decode_p("d" <> rest), do: decode_p(rest, %{})

  defp decode_p("i" <> rest) do
    int_pattern = ~r/^(?<num>(-?[1-9]+[1-9]*|[0-9]+))e/
    %{"num" => num} = Regex.named_captures(int_pattern, rest)
    
    int = num |> Integer.parse |> elem(0)
    
    offset = String.length(num) + 1
    tail = binary_part(rest, offset, byte_size(rest) - offset)

    {int, tail}
  end
  
  defp decode_p(data) do
    %{"size" => size} = Regex.named_captures(~r/^(?<size>[0-9]+):/, data)
    
    int = size |> Integer.parse |> elem(0)
    prefix = String.length(size) + 1
    
    string = binary_part(data, prefix, int)
    
    offset = prefix + int
    tail = binary_part(data, offset, byte_size(data) - offset)
    
    {string, tail}
  end

  defp decode_p("e" <> rest, acc) when is_list(acc), do: {Enum.reverse(acc), rest}
  defp decode_p("e" <> rest, acc) when is_map(acc), do: {acc, rest}

  defp decode_p(rest, acc) when is_list(acc) do
    {value, tail} = decode_p(rest)
    decode_p(tail, [value | acc])
  end

  defp decode_p(rest, acc) when is_map(acc) do
    {key, key_tail} = decode_p(rest)
    {value, tail} = decode_p(key_tail)
    decode_p(tail, Map.put(acc, key, value))
  end
  
  @doc """
  Encode Elixir data structures to a Bencode bitstring.
  
  An exception will be thrown if an unsupported data structure is provided.
  
  Args:
    * `data` - Data structure to encode.
  """
  @spec encode!(encodable) :: binary
  def encode!(data) when is_number(data), do: "i" <> Integer.to_string(data) <> "e"
  def encode!(data) when is_list(data), do: Enum.reduce(data, "l", &(&2 <> encode!(&1))) <> "e"
  def encode!(data) when is_map(data), do: Enum.reduce(data, "d", &(&2 <> encode!(&1))) <> "e"  
  def encode!(data) when is_atom(data), do: data |> Atom.to_string |> encode!
  def encode!({k, v}), do: encode!(k) <> encode!(v)
  def encode!(data), do: (data |> byte_size |> Integer.to_string) <> ":" <> data
  
  @doc """
  Encode Elixir data structures to a Bencode bitstring.
  
  The function will return `{:ok, bitstring}` on success or 
  `{:error, :invalid_format}` on failure.
  
  Args:
    * `data` - Data structure to encode.
  """
  @spec encode(encodable) :: {:ok, binary} | error_invalid_format
  def encode(data) do
    try do
      {:ok, encode!(data)}
    rescue
      _ -> {:error, :invalid_format}
    end
  end
end
