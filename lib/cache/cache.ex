defmodule SimpleCache do
  defmodule State do
    defstruct table: :simple_cache
  end

  use GenServer
  alias :ets, as: Ets

  @expired_after 6 * 60

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def set(key, value) do
    GenServer.cast(__MODULE__, {:set, key, value})
  end

  @doc """
  Custom TTL for cache entry
  ttl: Time to live in second
  """
  def set(key, value, ttl) do
    GenServer.cast(__MODULE__, {:set, key, value, ttl})
  end

  def get(state, key) do
    rs = Ets.lookup(state.table, key) |> List.first()

    if rs == nil do
      {:error, :not_found}
    else
      expired_at = elem(rs, 2)

      cond do
        NaiveDateTime.diff(NaiveDateTime.utc_now(), expired_at) > 0 ->
          {:error, :expired}

        true ->
          {:ok, elem(rs, 1)}
      end
    end
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  # state callbacks
  # state (callbacks)

  @impl true
  def init(state) do
    Ets.new(state.table, [:set, :protected, :named_table, read_concurrency: true])
    {:ok, state}
  end

  @doc """
  Default TTL
  """
  def handle_cast({:set, key, val}, state) do
    expired_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(@expired_after, :second)

    Ets.insert(state.table, {key, val, expired_at})
    {:noreply, state}
  end

  @doc """
  Custom TTL
  """
  def handle_cast({:set, key, val, ttl}, state) do
    inserted_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(ttl, :second)

    Ets.insert(state.table, {key, val, inserted_at})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    Ets.delete(state.table, key)
    {:noreply, state}
  end

  @moduledoc """
  A simple ETS based cache for expensive function calls.
  """

  @doc """
  Retrieve a cached value or apply the given function caching and returning
  the result.
  """
  def get(state, mod, fun, args, opts \\ []) do
    case lookup(state, mod, fun, args) do
      nil ->
        ttl = Keyword.get(opts, :ttl, 3600)
        cache_apply(mod, fun, args, ttl)

      result ->
        result
    end
  end

  @doc """
  Lookup a cached result and check the freshness
  """
  def lookup(state, mod, fun, args) do
    case get(state, [mod, fun, args]) do
      {:ok, data} ->
        IO.puts("HIT")
        data
      {:error, _} ->
        IO.puts("MISS")
        nil
    end
  end

  @doc """
  Apply the function, calculate expiration, and cache the result.
  """
  def cache_apply(mod, fun, args, ttl) do
    result = apply(mod, fun, args)
    expiration = ttl
    set([mod, fun, args], result, expiration)
    result
  end
end
