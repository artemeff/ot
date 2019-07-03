defmodule OT.Text.Transformation do
  @moduledoc """
  The transformation of two concurrent operations such that they satisfy the
  [TP1][tp1] property of operational transformation.

  [tp1]: https://en.wikipedia.org/wiki/Operational_transformation#Convergence_properties
  """

  alias OT.Text.{Component, Operation, Iterator}

  @doc """
  Transform an operation against another operation.

  Given an operation A that occurred at the same time as operation B against the
  same text state, transform the components of operation A such that the state
  of the text after applying operation A and then operation B is the same as
  after applying operation B and then the transformation of operation A against
  operation B:

  *S ○ Oa ○ transform(Ob, Oa) = S ○ Ob ○ transform(Oa, Ob)*

  This function also takes a third `side` argument that indicates which
  operation came later. This is important when deciding whether it is acceptable
  to break up insert components from one operation or the other.
  """
  @spec transform(Operation.t, Operation.t, OT.side) :: Operation.t
  def transform(op_a, op_b, side) do
    {op_a, op_b}
    |> next
    |> do_transform(side)
    |> drop_trailing_retain()
  end

  @spec do_transform(Iterator.output, OT.side, Operation.t) :: Operation.t
  defp do_transform(next_pair, side, result \\ [])

  # Operation A is exhausted
  defp do_transform({{nil, _}, _}, _, result) do
    result
  end

  # Operation B is exhausted
  defp do_transform({{head_a, tail_a}, {nil, _}}, _, result) do
    result
    |> Operation.append(head_a)
    |> Operation.join(tail_a)
  end

  # insert / insert / left
  defp do_transform({{head_a = %OT.Insert{}, tail_a},
                     {head_b = %OT.Insert{}, tail_b}}, :left, result) do
    {tail_a, [head_b | tail_b]}
    |> next
    |> do_transform(:left, Operation.append(result, head_a))
  end

  # insert / insert / right
  defp do_transform({{head_a = %OT.Insert{}, tail_a},
                     {head_b = %OT.Insert{}, tail_b}}, :right, result) do
    {[head_a | tail_a], tail_b}
    |> next
    |> do_transform(:right, Operation.append(result, %OT.Retain{v: Component.length(head_b)}))
  end

  # insert / retain
  defp do_transform({{head_a = %OT.Insert{}, tail_a},
                     {head_b = %OT.Retain{}, tail_b}}, side, result) do
    {tail_a, [head_b | tail_b]}
    |> next
    |> do_transform(side, Operation.append(result, head_a))
  end

  # insert / delete
  defp do_transform({{head_a = %OT.Insert{}, tail_a},
                     {head_b = %OT.Delete{}, tail_b}}, side, result) do
    {tail_a, [head_b | tail_b]}
    |> next
    |> do_transform(side, Operation.append(result, head_a))
  end

  # retain / insert
  defp do_transform({{head_a = %OT.Retain{}, tail_a},
                     {head_b = %OT.Insert{}, tail_b}}, side, result) do
    {[head_a | tail_a], tail_b}
    |> next
    |> do_transform(side, Operation.append(result, %OT.Retain{v: Component.length(head_b)}))
  end

  # retain / retain
  defp do_transform({{head_a = %OT.Retain{}, tail_a},
                     {%OT.Retain{}, tail_b}}, side, result) do
    {tail_a, tail_b}
    |> next
    |> do_transform(side, Operation.append(result, head_a))
  end

  # retain / delete
  defp do_transform({{%OT.Retain{}, tail_a},
                     {%OT.Delete{}, tail_b}}, side, result) do
    {tail_a, tail_b}
    |> next
    |> do_transform(side, result)
  end

  # delete / insert
  defp do_transform({{head_a = %OT.Delete{}, tail_a},
                     {head_b = %OT.Insert{}, tail_b}}, side, result) do
    {[head_a | tail_a], tail_b}
    |> next
    |> do_transform(side, Operation.append(result, %OT.Retain{v: Component.length(head_b)}))
  end

  # delete / retain
  defp do_transform({{head_a = %OT.Delete{}, tail_a},
                     {%OT.Retain{}, tail_b}}, side, result) do
    {tail_a, tail_b}
    |> next
    |> do_transform(side, Operation.append(result, head_a))
  end

  # delete / delete
  defp do_transform({{%OT.Delete{}, tail_a},
                     {%OT.Delete{}, tail_b}}, side, result) do
    {tail_a, tail_b}
    |> next
    |> do_transform(side, result)
  end

  @spec next(Iterator.input) :: Iterator.output
  defp next(scanner_input), do: OT.Text.Iterator.next(scanner_input, :insert)

  defp drop_trailing_retain(ops) do
    case List.last(ops) do
      %OT.Retain{} -> drop_trailing_retain(Enum.drop(ops, -1))
      _ -> ops
    end
  end
end
