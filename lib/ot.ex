defmodule OT do
  defmodule Delete do
    defstruct [:v]
  end

  defmodule Insert do
    defstruct [:v]
  end

  defmodule Retain do
    defstruct [:v]
  end

  @type side :: :left | :right

  def tipify(ops) do
    Enum.map(ops, fn
      (%{"d" => v}) ->
        %Delete{v: v}

      (%{d: v}) ->
        %Delete{v: v}

      (value) when is_binary(value) ->
        %Insert{v: value}

      (value) when is_integer(value) ->
        %Retain{v: value}

      (%{__struct__: type} = value) when type in [Delete, Insert, Retain] ->
        value

    end)
  end

  def untipify(ops) do
    Enum.map(ops, fn
      (%Delete{v: v}) -> %{d: v}
      (%Insert{v: v}) -> v
      (%Retain{v: v}) -> v
    end)
  end
end
