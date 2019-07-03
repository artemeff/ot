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
end
