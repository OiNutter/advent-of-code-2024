defmodule AdventOfCode.Input do
  @moduledoc """
  This module can help with automatically managing your Advent of Code input
  files. It will retrieve them once from the server and cache them to your
  machine.

  By default, it is configured to have network requests disabled. You can
  easily turn it on by editing the configuration.
  """

  @doc """
  Retrieves the specified input for your account. If the input is not in your
  cache, it will be retrieved from the server if `allow_network?: true` is
  configured and your cookie is setup.
  """
  def get!(day, year, example) do
    cond do
      in_cache?(day, year, example) ->
        from_cache!(day, year, example)

      allow_network?() ->
        download!(day, year)

      true ->
        raise "Cache miss for day #{day} of year #{year} and `:allow_network?` is not `true`"
    end
  end

  @doc """
  If, somehow, your input is invalid or mangled and you want to delete it from
  your cache so you can re-fetch it, this will save your bacon.
  Please don't use this to retrieve the input from the server repeatedly!
  """
  def delete!(day, year), do: File.rm!(cache_path(day, year))

  defp example_path(day, year), do: Path.join(cache_dir(), "/#{year}/#{day}.aocinput.example")
  defp cache_path(day, year), do: Path.join(cache_dir(), "/#{year}/#{day}.aocinput")
  defp in_cache?(day, year, example), do: File.exists?(if example, do: example_path(day, year), else: cache_path(day, year))

  defp store_in_cache!(day, year, input) do
    path = cache_path(day, year)
    :ok = path |> Path.dirname() |> File.mkdir_p()
    :ok = File.write(path, input)
  end

  defp from_cache!(day, year, example) do
    File.read!(if example, do: example_path(day, year), else: cache_path(day, year))
   end

  defp download!(day, year) do
    HTTPoison.start()

    {:ok, %{status_code: 200, body: input}} =
      HTTPoison.get("https://adventofcode.com/#{year}/day/#{day}/input", headers())

    store_in_cache!(day, year, input)

    to_string(input)
  end

  defp cache_dir do
    config()
    |> Keyword.get(
      :cache_dir,
      Path.join([System.get_env("XDG_CACHE_HOME", "~/.cache"), "/advent_of_code_inputs"])
    )
    |> Path.expand()
  end

  defp config, do: Application.get_env(:advent_of_code, __MODULE__)
  defp allow_network?, do: Keyword.get(config(), :allow_network?, false)

  defp headers,
    do: [cookie: "session=" <> Keyword.get(config(), :session_cookie)]
end
