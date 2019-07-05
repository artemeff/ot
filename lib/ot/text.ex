defmodule OT.Text do
  defstruct ops: []

  def new do
    %__MODULE__{}
  end

  def new(ops) do
    %__MODULE__{ops: OT.tipify(ops)}
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
