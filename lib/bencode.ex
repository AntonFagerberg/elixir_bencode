defmodule Bencode do
  def decode!(data) do
    case decode_p(data) do
      {result, ""} -> result
      _ -> raise("Unparsed trailing data.")
    end
  end

  def decode(data) do
    try do
      case decode_p(data) do
        {result, ""} -> {:ok, result}
        _ -> {:error, :trailingdata}
      end
    rescue
      _ -> {:error, :invalidformat}
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
  
  def encode(data) when is_number(data), do: "i" <> Integer.to_string(data) <> "e"
  def encode(data) when is_list(data), do: Enum.reduce(data, "l", &(&2 <> encode(&1))) <> "e"
  def encode(data) when is_map(data), do: Enum.reduce(data, "d", &(&2 <> encode(&1))) <> "e"  
  def encode(data) when is_atom(data), do: data |> Atom.to_string |> encode
  def encode({k, v}), do: encode(k) <> encode(v)
  def encode(data), do: (data |> String.length |> Integer.to_string) <> ":" <> data
end
