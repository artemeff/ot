defmodule OTTest do
  use ExUnit.Case
  doctest OT

  test "apply" do
    stream_case_file_json("./test/support/apply.json", fn(%{"str" => string, "op" => ops, "result" => result}) ->
      ops = OT.Text.new(ops)

      assert OT.Text.apply(ops, string) == {:ok, result}
    end)
  end

  test "compose" do
    stream_case_file_json("./test/support/compose.json", fn(%{"op1" => ops1, "op2" => ops2, "result" => result}) ->
      ops1 = OT.Text.new(ops1)
      ops2 = OT.Text.new(ops2)

      assert OT.Text.compose(ops1, ops2) == OT.Text.new(result)
    end)
  end

  test "transform" do
    stream_case_file_json("./test/support/transform.json", fn(%{"op" => ops1, "otherOp" => ops2, "side" => side, "result" => result}) ->
      side = make_side(side)
      ops1 = OT.Text.new(ops1)
      ops2 = OT.Text.new(ops2)

      assert OT.Text.transform(ops1, ops2, side) == OT.Text.new(result)
    end)
  end

  defp make_side("left"), do: :left
  defp make_side("right"), do: :right

  defp stream_case_file_json(file, callback) do
    file
    |> File.stream!([], :line)
    |> Stream.each(&(decode_and_call(&1, callback)))
    |> Stream.run()
  end

  defp decode_and_call(line, callback) do
    callback.(Jason.decode!(line))
  end
end
