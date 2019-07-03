defmodule OT.Text.Operation do
  @moduledoc """
  A list of components that iterates over and/or modifies a piece of text
  """

  alias OT.Text.Component

  @typedoc """
  An operation, which is a list consisting of `t:OT.Text.Component.retain/0`,
  `t:OT.Text.Component.insert/0`, and `t:OT.Text.Component.delete/0` components
  """
  @type t :: [Component.t]

  @doc """
  Append a component to an operation.

  ## Example

      iex> OT.Text.Operation.append([%OT.Insert{v: "Foo"}], %OT.Insert{v: "Bar"})
      [%OT.Insert{v: "FooBar"}]

  """
  @spec append(t, Component.t) :: t
  def append([], comp), do: [comp]
  def append(op, comp) do
    last_component = List.last(op)

    if Component.no_op?(comp) do
      op
    else
      op
      |> Enum.slice(0..-2)
      |> Kernel.++(Component.join(last_component, comp))
    end
  end

  @doc """
  Join two operations into a single operation.

  ## Example

      iex> OT.Text.Operation.join([%OT.Retain{v: 3}, %OT.Insert{v: "Foo"}], [%OT.Insert{v: "Bar"}, %OT.Retain{v: 4}])
      [%OT.Retain{v: 3}, %OT.Insert{v: "FooBar"}, %OT.Retain{v: 4}]

      iex> OT.Text.Operation.join([%OT.Retain{v: 3}, %OT.Insert{v: "Foo"}], [%OT.Insert{v: "Bar"}, %OT.Insert{v: "Bar"}, %OT.Retain{v: 4}])
      [%OT.Retain{v: 3}, %OT.Insert{v: "FooBarBar"}, %OT.Retain{v: 4}]

  """
  @spec join(t, t) :: t
  def join([], op_b), do: op_b
  def join(op_a, []), do: op_a

  def join(op_a, op_b) do
    Enum.reduce(op_b, op_a, fn(join, result) ->
      append(result, join)
    end)
  end
end
