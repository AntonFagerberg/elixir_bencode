defmodule Bencode do
  def decode!(data) do
    case decode_p(data) do
      {result, ""} -> result
      {_, tail} -> raise("Unparsed trailing data: #{tail}")
    end
  end

  def decode(data) do
    case decode_p(data) do
      {result, ""} -> {:ok, result}
      {_, tail} -> {:error, tail}
    end
  end

  defp decode_p("l" <> rest), do: decode_p(rest, [])
  defp decode_p("d" <> rest), do: decode_p(rest, %{})

  defp decode_p("i" <> rest) do
    int_pattern = ~r/(?<num>^(-?[1-9]+[1-9]*|[0-9]+))e(?<tail>.*)/
    %{"num" => num, "tail" => tail} = Regex.named_captures(int_pattern, rest)
    
    {num |> Integer.parse |> elem(0), tail}
  end

  defp decode_p(data) do
    %{"size" => size} = Regex.named_captures(~r/^(?<size>[0-9]+):/, data)
    
    data
    |> String.split_at(String.length(size) + 1)
    |> elem(1)
    |> String.split_at(size |> Integer.parse |> elem(0))
  end


  defp decode_p("e" <> rest, acc) when is_list(acc), do: {Enum.reverse(acc), rest}
  defp decode_p("e" <> rest, acc), do: {acc, rest}

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
  def encode({k, v}), do: encode(k) <> encode(v)
  def encode(data) when is_atom(data), do: data |> Atom.to_string |> encode
  def encode(data), do: (data |> String.length |> Integer.to_string) <> ":" <> data
end
