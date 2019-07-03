defmodule OT.Text.Iterator do
  alias OT.Text.{Component, Operation}

  @typedoc "A type which is not to be split when iterating"
  @type skip_type :: :delete | :insert | nil

  @typedoc """
  The input to the scanner—a tuple containing two operations
  """
  @type input :: {Operation.t, Operation.t}

  @typedoc """
  An operation's next scanned full or partial component, and its resulting
  tail operation
  """
  @type operation_split :: {Component.t | nil, Operation.t}

  @typedoc """
  A tuple representing the new head component and tail operation of the two
  operations being scanned over
  """
  @type output :: {operation_split, operation_split}

  @doc """
  Given a pair of two operations, return the next two full or partial components
  where the second component potentially affects the first.
  A third parameter may be passed that specifies that components of a given
  type are not to be split up: For example, when transforming operation `a`
  over operation `b`, the insert operations from `a` should not be split in
  order to preserve user intent.
  When any operation's components are exhausted, it will be represented by
  the tuple `{nil, []}`.

  ## Examples

      iex> OT.Text.Iterator.next({[%OT.Retain{v: 4}, %OT.Insert{v: "Foo"}], [%OT.Retain{v: 2}]})
      {{%OT.Retain{v: 2}, [%OT.Retain{v: 2}, %OT.Insert{v: "Foo"}]}, {%OT.Retain{v: 2}, []}}

      iex> OT.Text.Iterator.next({[%OT.Insert{v: "Foo"}], [%OT.Retain{v: 2}]}, :insert)
      {{%OT.Insert{v: "Foo"}, []}, {%OT.Retain{v: 2}, []}}

      iex> OT.Text.Iterator.next({[%OT.Delete{v: 3}], [%OT.Retain{v: 2}]})
      {{%OT.Delete{v: 2}, [%OT.Delete{v: 1}]}, {%OT.Retain{v: 2}, []}}

  """
  @spec next(input, skip_type) :: output
  def next(input, skip_type \\ nil)

  # Both operations are exhausted.
  def next({[], []}, _), do: {{nil, []}, {nil, []}}

  # Operation a is exhausted.
  def next({[], [head_b | tail_b]}, _), do: {{nil, []}, {head_b, tail_b}}

  # Operation b is exhausted.
  def next({[head_a | tail_a], []}, _), do: {{head_a, tail_a}, {nil, []}}

  def next(result = {[head_a | tail_a], [head_b | tail_b]}, skip_type) do
    cond do
      Component.no_op?(head_a) && Component.no_op?(head_b) ->
        next({tail_a, tail_b}, skip_type)

      Component.no_op?(head_a) ->
        next({tail_a, [head_b | tail_b]}, skip_type)

      Component.no_op?(head_b) ->
        next({[head_a | tail_a], tail_b}, skip_type)

      true ->
        do_next(result,
          Component.compare(head_a, head_b),
          Component.type(head_a) == skip_type)
    end
  end

  # A > B and is splittable, so split A
  @spec do_next(input, Component.comparison, boolean) :: output
  defp do_next({[head_a | tail_a], [head_b | tail_b]}, :gt, false) do
    {head_a, remainder_a} = Component.split(head_a, Component.length(head_b))
    {{head_a, [remainder_a | tail_a]}, {head_b, tail_b}}
  end

  # B < A, so split B
  defp do_next({[head_a | tail_a], [head_b | tail_b]}, :lt, _) do
    {head_b, remainder_b} = Component.split(head_b, Component.length(head_a))
    {{head_a, tail_a}, {head_b, [remainder_b | tail_b]}}
  end

  # A > B and is not splittlable, or A == B, so do not split
  defp do_next({[head_a | tail_a], [head_b | tail_b]}, _, _) do
    {{head_a, tail_a}, {head_b, tail_b}}
  end
end
