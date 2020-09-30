defmodule ThemaVerbi.StatelessProperty do
  use GenServer, restart: :transient, shutdown: 30_000

  # Client API

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    start_link([])
  end

  @spec start_link(maybe_improper_list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default,  name: __MODULE__)
  end

  @spec push(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  @spec push(any) :: :ok
  def push(element) do
    GenServer.cast(__MODULE__, {:push, element})
  end

  @spec pop(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  @spec pop :: any
  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  ##
  ## callbacks
  #

  @impl true
  @spec init(any) :: {:ok, any}
  def init(stack) do
    {:ok, stack}
  end

  ## call

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    IO.inspect(length(tail), label: "rest stack depth")
    {:reply, head, tail}
  end

  ## cast

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

  ## info

  @impl true
  def handle_info(_event, state) do
    {:noreply, state}
  end

  ##
  ## internals
  #

end
