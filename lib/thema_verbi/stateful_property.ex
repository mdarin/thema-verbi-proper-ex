defmodule ThemaVerbi.StatefulProperty do
  use GenStateMachine
  @moduledoc """
  StateMachine https://hexdocs.pm/gen_state_machine/GenStateMachine.html

  Робот пылесос может находится в одном из следущих состояниий:
  robot vacuum cleaner has got a number of states
  homing(базирование)
  scena(место действия)
  vacuum cleaning(уборка по месту)
  collectin data(сбор данных)
  making map (постороение карты)
  scavenging(управление щетками для сгребания мусора)
  finishing(окончание уборки)
  low_battery(низки заряд батареи)
  overload(загрузка мусорного контейнера)

  Возможные переходы
  Transitions

     -> homing

  homing -> scena

  scena -> vacuum_cleaning

  vacuum_cleaning -> collecting_data
  vacuum_cleaning -> low_battery
  vacuum_cleaning -> overload
  vacuum_cleaning -> finishing

  collecting_data -> making_map

  making_map -> scavenging

  scavenging -> vacuum_cleaning
  scavenging -> collecting_data

  low_battery -> homing

  overload -> homing

  finishing -> homing

  * -> fault # from every state

  fault -> homing

  Testing prerequisite is folloving statement.
  Our robot cannot make a transition to arbitrary state.
  It can migrate only to hard defined positions.
  """

  ##
  ## API
  #

  # {:ok, pid} =

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:off, 0}, name: __MODULE__)
  end

  @spec start_link(atom) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(:robot) do
    GenStateMachine.start_link(__MODULE__, {:on, :some_data_here}, name: __MODULE__)
  end

  @spec flip(atom | pid | {atom, any} | {:via, atom, any}) :: :ok
  def flip(pid) do
    GenStateMachine.cast(pid, :flip)
  end

  @spec run_robot_vacuumcleaner(atom | pid | {atom, any} | {:via, atom, any}) :: :ok
  def run_robot_vacuumcleaner(pid) do
    GenStateMachine.cast(pid, :homing)
  end

  @spec get_count(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def get_count(pid) do
    GenStateMachine.call(pid, :get_count)
  end

  ##
  ## callbacks)
  #

  @impl true
  def init({state, data}) do
    IO.inspect(state, label: "state")
    IO.inspect(data, label: "data")
    {:ok, state, data}
  end

  @impl true
  @spec terminate(reason :: term(), state :: term(), data :: term()) :: any()
  def terminate(_reason, _state, _data) do
    :ok
  end

  ## cast

  @impl true
  def handle_event(:cast, :flip, :off, data) do
    IO.inspect(data, label: "data")
    {:next_state, :on, data + 1}
  end

  def handle_event(:cast, :flip, :on, data) do
    # {:next_state, :off, data}

    time = 3000
    event_content = :flip
    new_data = data
    next_state = :off

    # по аналогии настраиваются и другие таймауты
    # http://erlang.org/doc/man/gen_statem.html#type-timeout_action
    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  def handle_event(:cast, :homing, :on, data) do
    IO.puts("ON -> initializing")
    time = 3000
    event_content = :homing
    new_data = data
    next_state = :init

    # по аналогии настраиваются и другие таймауты
    # http://erlang.org/doc/man/gen_statem.html#type-timeout_action
    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  ## timeout

  @impl true
  def handle_event(:timeout, :flip, :off, data) do
    IO.inspect(data, label: "timeout data")
    {:next_state, :on, data + 1}
  end

  # homing -> scena
  def handle_event(:timeout, :homing, :init, data) do
    IO.puts("homing -> scena")
    time = 3000
    event_content = :scena
    new_data = data
    next_state = :movement

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  # scena -> vacuum_cleaning
  def handle_event(:timeout, :scena, :movement, data) do
    IO.puts("scena -> vacuum_cleaning")
    time = 3000
    event_content = :vacuum_cleaning
    new_data = data
    next_state = :clean

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  # vacuum_cleaning -> collecting_data
  # vacuum_cleaning -> overload
  # vacuum_cleaning -> low_battery
  # vacuum_cleaning -> finishing
  def handle_event(:timeout, :vacuum_cleaning, :clean, data) do
    IO.puts("vacuum_cleaning -> collecting_data")
    time = 3000
    event_content = :collecting_data # | :finishing | :low_battery | :overload
    new_data = data
    next_state = :collect # | :parcking | :charging | :unloading

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  # collecting_data -> making_map
  def handle_event(:timeout, :collecting_data, :collect, data) do
    IO.puts("collecting_data -> making_map")
    time = 3000
    event_content = :making_map
    new_data = data
    next_state = :actualize

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  # overload -> homing
  def handle_event(:timeout, :overload, :unloading, data) do
    IO.puts("overload -> homing")
    time = 3000
    event_content = :homing
    new_data = data
    next_state = :init

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  # low_battery -> homing
  def handle_event(:timeout, :low_battry, :charging, data) do
    IO.puts("low_battery -> homing")
    time = 3000
    event_content = :homing
    new_data = data
    next_state = :init

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  # finishing -> homing
  def handle_event(:timeout, :finishing, :parcking, data) do
    IO.puts("finishing -> homing")
    time = 3000
    event_content = :homing
    new_data = data
    next_state = :init

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  # making_map -> scavenging
  def handle_event(:timeout, :making_map, :actualize, data) do
    IO.puts("making_map -> scavenging")
    time = 3000
    event_content = :scavenging
    new_data = data
    next_state = :raking_garbage

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end

  # scavenging -> vacuum_cleaning
  # scavenging -> collecting_data
  def handle_event(:timeout, :scavenging, :raking_garbage, data) do
    IO.puts("scavenging -> vacuum_cleaning")
    time = 3000
    event_content = :vacuum_cleaning # | :collecting_data
    new_data = data
    next_state = :clean # | :collect

    action = {
      :timeout,
      time, # ms
      event_content # содержимое эвента
    }

    {:next_state, next_state, new_data, action}
  end




  # * -> fault # from every state

  # fault -> homing

  ## calls

  @impl true
  def handle_event({:call, from}, :get_count, state, data) do
    {:next_state, state, data, [{:reply, from, data}]}
  end

  ## info

  # If you want to receive custom messages, they will be delivered
  # to the usual handler for your callback mode with event_type :info
  @impl true
  def handle_event(:info, _event, state, data) do
    {:next_state, state, data}
  end

  ## default handler

  def handle_event(event_type, event_content, state, data) do
    # Call the default implementation from GenStateMachine
    super(event_type, event_content, state, data)
  end

end
