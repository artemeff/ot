defmodule OT.Text do
  defstruct ops: []

  def new do
    %__MODULE__{}
  end

  def new(ops) do
    %__MODULE__{ops: tipify(ops)}
  end

  def tipify(ops) do
    Enum.map(ops, fn
      (%{"d" => v}) ->
        %OT.Delete{v: v}

      (%{d: v}) ->
        %OT.Delete{v: v}

      (value) when is_binary(value) ->
        %OT.Insert{v: value}

      (value) when is_integer(value) ->
        %OT.Retain{v: value}

      (%{__struct__: type} = value) when type in [OT.Delete, OT.Insert, OT.Retain] ->
        value

    end)
  end

  def apply(%__MODULE__{ops: ops}, document) do
    OT.Text.Application.apply(document, ops)
  end

  def apply!(%__MODULE__{ops: ops}, document) do
    OT.Text.Application.apply!(document, ops)
  end

  def compose(%__MODULE__{ops: ops1}, %__MODULE__{ops: ops2}) do
    %__MODULE__{ops: OT.Text.Composition.compose(ops1, ops2)}
  end

  def transform(%__MODULE__{ops: ops1}, %__MODULE__{ops: ops2}, side) do
    %__MODULE__{ops: OT.Text.Transformation.transform(ops1, ops2, side)}
  end
end
