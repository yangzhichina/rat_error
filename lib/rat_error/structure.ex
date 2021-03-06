defmodule RatError.Structure do
  @moduledoc """
  Specifies the Map structure of a RAT error.

  This struct could be created from the specified options as below,

  [
    node:   :error,
    prefix: nil,
    keys:   [:code, :message]
  ]

  References the 'RatError.Structure' configuration in 'config/*.exs' for
  detail.
  """

  alias __MODULE__
  require Logger

  defstruct [:node, :prefix, :keys]

  @support_keys [
    # Error code defined by caller, e.g. an atom :no_entry, an integer 9 or a
    # string "unexpected".
    :code,

    # Error file path.
    :file,

    # Error function name.
    :function,

    # Error file line.
    :line,

    # Error message of string passed in by caller.
    :message,

    # Error module.
    :module
  ]

  @doc """
  Creates the struct from the default 'RatError.Structure' configuration.

  The default configuration is set in 'config/*.exs'.

  ## Examples

  References 'config/test.exs' for the test configuration.

  iex> Structure.create_from_default_config
  %RatError.Structure
    {
      node:   :error,
      prefix: nil,
      keys:
      [
        :code,
        :file,
        :function,
        :line,
        :message,
        :module
      ]
    }

  """
  def create_from_default_config do
    :rat_error
    |> Application.get_env(RatError.Structure)
    |> create
  end

  @doc """
  Creates the struct from the specified options.

  ## Examples

  iex> Structure.create(node: :err, keys: [:code, :message])
  %RatError.Structure
    {
      node:   :err,
      prefix: nil,
      keys:   [:code, :message]
    }

  iex> Structure.create(prefix: :err, keys: [:code, :message])
  %RatError.Structure
    {
      node:   nil,
      prefix: :err,
      keys:   [:code, :message]
    }

  iex> Structure.create(keys: :code)
  %RatError.Structure
    {
      node:   nil,
      prefix: nil,
      keys:   [:code]
    }

  """
  def create(opts) when is_list(opts) do
    keys = filter_keys(opts[:keys])

    %Structure{node: opts[:node], prefix: opts[:prefix], keys: keys}
  end

  @doc """
  Updates the struct with the specified options.

  ## Examples

  iex> structure = %Structure{node: :err, keys: [:code]}
  iex> Structure.update(structure, node: :error, prefix: :err, keys: :message)
  %RatError.Structure
    {
      node:   :error,
      prefix: :err,
      keys:   [:message]
    }

  """
  def update(%Structure{} = structure, opts) when is_list(opts) do
    params =
      Enum.reduce([:node, :prefix, :keys], %{},
        fn(k, acc) ->
          case Keyword.fetch(opts, k) do
            {:ok, v} -> Map.put(acc, k, v)
            :error   -> acc
          end
        end)

    params =
      if keys = params[:keys] do
        %{params | keys: filter_keys(keys)}
      else
        params
      end

    Map.merge(structure, params)
  end

  defp filter_keys(keys) do
    keys          = List.wrap(keys)
    filtered_keys = keys -- (keys -- @support_keys)

    if is_nil(List.first(filtered_keys)) do
      Logger.warn("there is no support keys - '#{inspect(keys)}'!")
    end

    filtered_keys
  end
end
