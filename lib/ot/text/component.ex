defmodule OT.Text.Component do
  alias OT.Text.Operation

  @typedoc """
  A delete component, in which a string of zero or more characters are deleted
  from the text
  """
  @type delete :: %OT.Delete{v: non_neg_integer}

  @typedoc """
  An insert component, in which a string of zero or more characters are inserted
  into the text
  """
  @type insert :: %OT.Insert{v: String.t}

  @typedoc """
  A retain component, in which a number of characters in the text are skipped
  over
  """
  @type retain :: %OT.Retain{v: non_neg_integer}

  @typedoc """
  An atom declaring the type of a component
  """
  @type type :: :delete | :insert | :retain

  @typedoc """
  The result of comparing two components
  """
  @type comparison :: :eq | :gt | :lt

  @typedoc """
  A single unit of "work" performed on a piece of text
  """
  @type t :: delete | insert | retain

  @doc """
  Determine the length of a component.

  ## Examples

      iex> OT.Text.Component.length(%OT.Retain{v: 4})
      4

      iex> OT.Text.Component.length(%OT.Insert{v: "Foo"})
      3

  """
  @spec length(t) :: non_neg_integer
  def length(%OT.Retain{v: v}), do: v
  def length(%OT.Delete{v: v}), do: v
  def length(%OT.Insert{v: v}), do: String.length(v)

  @doc """
  Determine the type of a component.

  ## Examples

      iex> OT.Text.Component.type(%OT.Retain{v: 4})
      :retain

      iex> OT.Text.Component.type(%OT.Insert{v: "Foo"})
      :insert

      iex> OT.Text.Component.type(%OT.Delete{v: "Foo"})
      :delete

  """
  @spec type(t) :: type
  def type(%OT.Retain{}), do: :retain
  def type(%OT.Delete{}), do: :delete
  def type(%OT.Insert{}), do: :insert

  @doc """
  Compare the length of two components.
  Will return `:gt` if first is greater than second, `:lt` if first is less
  than second, or `:eq` if they span equal lengths.

  ## Example

      iex> OT.Text.Component.compare(%OT.Insert{v: "Foo"}, %OT.Retain{v: 1})
      :gt

  """
  @spec compare(t, t) :: comparison
  def compare(comp_a, comp_b) do
    length_a = __MODULE__.length(comp_a)
    length_b = __MODULE__.length(comp_b)

    cond do
      length_a > length_b -> :gt
      length_a < length_b -> :lt
      true -> :eq
    end
  end

  @doc """
  Join two components into an operation, combining them into a single component
  if they are of the same type.

  ## Example

      iex> OT.Text.Component.join(%OT.Insert{v: "Foo"}, %OT.Insert{v: "Bar"})
      [%OT.Insert{v: "FooBar"}]

  """
  @spec join(t, t) :: Operation.t
  def join(%OT.Retain{v: a}, %OT.Retain{v: b}),
    do: [%OT.Retain{v: a + b}]
  def join(%OT.Insert{v: ins_a}, %OT.Insert{v: ins_b}),
    do: [%OT.Insert{v: ins_a <> ins_b}]
  def join(%OT.Delete{v: del_a}, %OT.Delete{v: del_b}),
    do: [%OT.Delete{v: del_a + del_b}]
  def join(comp_a, comp_b),
    do: [comp_a, comp_b]

  @doc """
  Determine whether a comopnent is a no-op.

  ## Examples

      iex> OT.Text.Component.no_op?(%OT.Retain{v: 0})
      true

      iex> OT.Text.Component.no_op?(%OT.Insert{v: ""})
      true

      iex> OT.Text.Component.no_op?(%OT.Insert{v: "text"})
      false

  """
  @spec no_op?(t) :: boolean
  def no_op?(%OT.Retain{v: 0}), do: true
  def no_op?(%OT.Delete{v: 0}), do: true
  def no_op?(%OT.Insert{v: ""}), do: true
  def no_op?(_), do: false

  @doc """
  Split a component at a given index.
  Returns a tuple containing a new component before the index, and a new
  component after the index.

  ## Examples

      iex> OT.Text.Component.split(%OT.Retain{v: 4}, 3)
      {%OT.Retain{v: 3}, %OT.Retain{v: 1}}

      iex> OT.Text.Component.split(%OT.Insert{v: "Foo"}, 2)
      {%OT.Insert{v: "Fo"}, %OT.Insert{v: "o"}}

  """
  @spec split(t, non_neg_integer) :: {t, t}
  def split(%OT.Retain{v: v}, index) do
    {%OT.Retain{v: index}, %OT.Retain{v: v - index}}
  end

  def split(%OT.Delete{v: v}, index) do
    {%OT.Delete{v: index}, %OT.Delete{v: v - index}}
  end

  def split(%OT.Insert{v: v}, index) do
    {%OT.Insert{v: String.slice(v, 0, index)}, %OT.Insert{v: String.slice(v, index..-1)}}
  end
end
