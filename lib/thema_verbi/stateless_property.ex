defmodule ThemaVerbi.StatelessProperty do
  use GenServer, restart: :transient, shutdown: 30_000

  @moduledoc """
  Stack model
  Imagine that we have got some memory unit.
  The memory unit contains 8 registers.
  Every register consists of 16 cells to store numbers.
  Number per cell.
  """

  # count of available registers in whole memory unit
  @nregs 8
  # count of available cells in every register
  @ncells 16

  @type element() ::
          number()
          | list(number())

  # Client API

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    start_link([])
  end

  @spec start_link(maybe_improper_list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) when is_list(args) do
    name = Keyword.get(args, :name, __MODULE__)
    stack = Keyword.get(args, :stack, [])
    GenServer.start_link(__MODULE__, stack, name: name)
  end

  @spec stop(any) :: :ok
  def stop(reason) do
    GenServer.cast(__MODULE__, {:stop, reason})
  end

  @spec stop(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def stop(pid, reason) do
    GenServer.cast(pid, {:stop, reason})
  end

  @spec push(atom | pid | {atom, any} | {:via, atom, any}, element()) :: :ok
  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  @spec push(element()) :: :ok
  def push(element) do
    GenServer.cast(__MODULE__, {:push, element})
  end

  @spec pop(atom | pid | {atom, any} | {:via, atom, any}) :: element() | :empty
  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  @spec pop :: element() | :empty
  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  @spec get_depth(atom | pid | {atom, any} | {:via, atom, any}) :: pos_integer()
  def get_depth(pid) do
    GenServer.call(pid, :get_depth)
  end

  @spec get_depth :: pos_integer()
  def get_depth do
    GenServer.call(__MODULE__, :get_depth)
  end

  ##
  ## callbacks
  #

  @impl true
  @spec init(any) :: {:ok, any}
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  @spec terminate(:normal | :shutdown | {:shutdown, term()} | term(), term()) :: :ok
  def terminate(_reason, _state) do
    IO.puts("terminated")
    :ok
  end

  ## call

  @impl true
  def handle_call(:pop, _from, [] = state) do
    depth = length(state)
    IO.inspect(depth, label: "rest stack depth")
    {:reply, :empty, state}
  end

  def handle_call(:pop, _from, [head | tail]) do
    depth = length(tail)
    IO.inspect(depth, label: "rest stack depth")
    {:reply, head, tail}
  end

  def handle_call(:get_depth, _from, state) do
    depth = length(state)
    {:reply, depth, state}
  end

  def handle_call(_message, _from, state) do
    {:noreply, state}
  end

  ## cast

  @impl true
  def handle_cast({:stop, reason}, state) do
    IO.puts("stopped")
    {:stop, reason, state}
  end

  def handle_cast({:push, [head | _tail] = element}, state)
      when is_list(element) and is_number(head) do
    size = length(element)

    if size >= @ncells do
      IO.puts("Out of range")
      IO.inspect(size, label: "size")
      # make a crash
      # size / 0
      {:noreply, state}
    else
      new_state = [element | state]
      depth = length(new_state)
      IO.inspect(depth, label: "new stack depth")
      {:noreply, new_state}
    end
  end

  def handle_cast({:push, element}, state) when is_number(element) do
    depth = length(state) + 1

    if depth >= @nregs do
      IO.puts("Overflow")
      # make a crash
      # depth / 0
      {:noreply, state}
    else
      IO.inspect(depth, label: "new stack depth")
      new_state = [element | state]
      {:noreply, new_state}
    end
  end

  def handle_cast({:push, _element}, state) do
    IO.puts("Unknown entity type")
    {:noreply, state}
  end

  def handle_cast(_message, state) do
    {:noreply, state}
  end

  ## info

  @impl true
  def handle_info(_message, state) do
    {:noreply, state}
  end

  ##
  ## internals
  #
end
