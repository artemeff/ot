defmodule OT.Text.Composition do
  @moduledoc """
  The composition of two non-concurrent operations into a single operation.
  """

  alias OT.Text.{Operation, Iterator}

  @doc """
  Compose two operations into a single equivalent operation.
  The operations are composed in such a way that the resulting operation has the
  same effect on document state as applying one operation and then the other:
  *S ○ compose(Oa, Ob) = S ○ Oa ○ Ob*.

  ## Example

      iex> OT.Text.Composition.compose([%OT.Insert{v: "Bar"}], [%OT.Insert{v: "Foo"}])
      [%OT.Insert{v: "FooBar"}]

  """
  @spec compose(Operation.t, Operation.t) :: Operation.t
  def compose(op_a, op_b) do
    {op_a, op_b}
    |> next
    |> do_compose
  end

  @spec do_compose(Iterator.output, Operation.t) :: Operation.t
  defp do_compose(next_pair, result \\ [])

  # Both operations are exhausted.
  defp do_compose({{nil, _}, {nil, _}}, result) do
    result
  end

  # A is exhausted.
  defp do_compose({{nil, _}, {head_b, tail_b}}, result) do
    result
    |> Operation.append(head_b)
    |> Operation.join(tail_b)
  end

  # B is exhausted.
  defp do_compose({{head_a, tail_a}, {nil, _}}, result) do
    result
    |> Operation.append(head_a)
    |> Operation.join(tail_a)
  end

  # _ / insert
  defp do_compose({{head_a, tail_a}, {head_b = %OT.Insert{}, tail_b}}, result) do
    {[head_a | tail_a], tail_b}
    |> next
    |> do_compose(Operation.append(result, head_b))
  end

  # insert / retain
  defp do_compose({{head_a = %OT.Insert{}, tail_a}, {%OT.Retain{}, tail_b}}, result) do
    {tail_a, tail_b}
    |> next
    |> do_compose(Operation.append(result, head_a))
  end

  # insert / delete
  defp do_compose({{%OT.Insert{}, tail_a}, {%OT.Delete{}, tail_b}}, result) do
    {tail_a, tail_b}
    |> next
    |> do_compose(result)
  end

  # retain / retain
  defp do_compose({{retain_a = %OT.Retain{}, tail_a}, {%OT.Retain{}, tail_b}}, result) do
    {tail_a, tail_b}
    |> next
    |> do_compose(Operation.append(result, retain_a))
  end

  # retain / delete
  defp do_compose({{%OT.Retain{}, tail_a}, {head_b = %OT.Delete{}, tail_b}}, result) do
    {tail_a, tail_b}
    |> next
    |> do_compose(Operation.append(result, head_b))
  end

  # delete / retain
  defp do_compose({{head_a = %OT.Delete{}, tail_a}, {retain_b = %OT.Retain{}, tail_b}}, result) do
    {tail_a, [retain_b | tail_b]}
    |> next
    |> do_compose(Operation.append(result, head_a))
  end

  # delete / delete
  defp do_compose({{head_a = %OT.Delete{}, tail_a}, {head_b = %OT.Delete{}, tail_b}}, result) do
    {tail_a, [head_b | tail_b]}
    |> next
    |> do_compose(Operation.append(result, head_a))
  end

  @spec next(Iterator.input) :: Iterator.output
  defp next(scanner_input), do: OT.Text.Iterator.next(scanner_input, :delete)
end
