defmodule Elixpath.Parser do
  @moduledoc """
  Parses Elixpath expressions.
  """
  import NimbleParsec

  @type option :: {:unsafe_atom, boolean} | {:prefer_keys, :string | :atom}

  defmodule ParseError do
    @moduledoc """
    Syntax error while parsing Elixpath string.
    """
    defexception [:message]
  end

  defparsecp(:parse_path, __MODULE__.Grammar.path())

  @doc """
  Parses an Elixpath expression.
  See [this page](readme.html) for syntax.

  Warning: when `unsafe_atom: true` is specified, this function creates new atom using `String.to_atom/1`.
  Do not specify `unsafe_atom: true` for untrusted input.
  See `String.to_atom/1` for details.

  ## Options

    - `:unsafe_atom` - if `true`, allows to create non-existing atoms, defaults to `false`.
    - `:prefer_keys` - unquoted keys are converted to string (`:string`) or atom (`:atom`). Defaults to `:string`.
  """
  @spec path(String.t(), [option]) :: {:ok, Elixpath.path()} | {:error, reason :: term}
  def path(str, opts \\ []) do
    case parse_path(str, context: %{opts: opts}) do
      {:ok, result, "", _context, _line, _column} ->
        {:ok, result}

      {:ok, result, rest, _context, _line, _column} ->
        {:error, "did not reach the end of string. result: #{inspect(result)}, rest: #{rest}"}

      {:error, reason, _rest, _context, _line, _column} ->
        {:error, reason}
    end
  end

  @doc """
  Parses an Elixpath expression.
  Raises on error.
  See `path/2` for available options.
  """
  @spec path!(String.t(), [option]) :: Elixpath.path() | no_return
  def path!(str, opts \\ []) do
    case path(str, opts) do
      {:ok, result} -> result
      {:error, reason} -> raise Elixpath.Parser.ParseError, message: reason
    end
  end
end
