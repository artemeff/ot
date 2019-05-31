defmodule OtTest do
  use ExUnit.Case
  doctest Ot

  test "greets the world" do
    assert Ot.hello() == :world
  end
end
