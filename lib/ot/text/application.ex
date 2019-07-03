defmodule OT.Text.Application do
  @moduledoc """
  The application of a text operation to a piece of text.
  """

  alias OT.Text.Operation

  @typedoc """
  The result of an `apply/2` function call, representing either success or error
  in application of an operation
  """
  @type apply_result :: {:ok, String.t}
                      | {:error, :delete_mismatch | :retain_too_long}

  @doc """
  Apply an operation to a piece of text.

  Given a piece of text and an operation, iterate over each component in the
  operation and apply it to the given text. If the operation is valid, the
  function will return `{:ok, new_state}` where `new_state` is the text with
  the operation applied to it. If the operation is invalid, an
  `{:error, atom}` tuple will be returned.

  ## Examples

      iex> OT.Text.Application.apply("Foo", [%OT.Retain{v: 3}, %OT.Insert{v: " Bar"}])
      {:ok, "Foo Bar"}

      iex> OT.Text.Application.apply("Foo", [%OT.Delete{v: 4}])
      {:error, :delete_mismatch}

  ## Errors

  - `:delete_mismatch` A delete component did not match the text it would have
    deleted in the text
  - `:retain_too_long` A retain component skipped past the end of the text
  """
  @spec apply(String.t, Operation.t) :: apply_result
  def apply(text, op), do: do_apply(text, op)

  @doc """
  Same as `apply/2`, but raises if the application fails.
  """
  @spec apply!(String.t, Operation.t) :: String.t | no_return
  def apply!(text, op) do
    with {:ok, result} <- __MODULE__.apply(text, op) do
      result
    else
      {:error, error} -> raise to_string(error)
    end
  end

  @spec do_apply(String.t, Operation.t, String.t) :: apply_result
  defp do_apply(text, op, result \\ "")

  defp do_apply(text, [], result) do
    {:ok, result <> text}
  end

  defp do_apply(text, [%OT.Delete{v: value} | op], result) do
    {deleted, text} = String.split_at(text, value)

    if value == String.length(deleted) do
      text
      |> do_apply(op, result)
    else
      {:error, :delete_mismatch}
    end
  end

  defp do_apply(text, [%OT.Insert{v: value} | op], result) do
    text
    |> do_apply(op, result <> value)
  end

  defp do_apply(text, [%OT.Retain{v: value} | op], result) do
    if value <= String.length(text) do
      {retained, text} = String.split_at(text, value)

      text
      |> do_apply(op, result <> retained)
    else
      {:error, :retain_too_long}
    end
  end
end
