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

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:off, 0}, name: __MODULE__)
  end

  @spec start_link(atom) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) when is_atom(state) do
    GenStateMachine.start_link(__MODULE__, state, name: __MODULE__)
  end

  @spec flip(atom | pid | {atom, any} | {:via, atom, any}) :: :ok
  def flip(pid) do
    GenStateMachine.cast(pid, :flip)
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

  def handle_event(:timeout, :flip, :off, data) do
    IO.inspect(data, label: "timeout data")
    {:next_state, :on, data + 1}
  end

  # все эти состояния будут реализованы обработчиках таймаута

  # homing -> scena
  # def handle_event()
  # {next_state,
  #    NextState :: StateType,
  #    NewData :: data(),
  #    Actions :: action()}

  #    actrion() ::
  #    {state_timeout,
  #    Time :: state_timeout(),
  #    EventContent :: term(),
  #    Options :: timeout_option()}

  #    timeout_option() ::
  #    {next_event,
  #    EventType :: event_type(), # :cast
  #    EventContent :: term()} # содержание эвента

  # scena -> vacuum_cleaning

  # vacuum_cleaning -> collecting_data
  # vacuum_cleaning -> low_battery
  # vacuum_cleaning -> overload
  # vacuum_cleaning -> finishing

  # collecting_data -> making_map

  # making_map -> scavenging

  # scavenging -> vacuum_cleaning
  # scavenging -> collecting_data

  # low_battery -> homing

  # overload -> homing

  # finishing -> homing

  # * -> fault # from every state

  # fault -> homing

  ## calls

  @impl true
  def handle_event({:call, from}, :get_count, state, data) do
    {:next_state, state, data, [{:reply, from, data}]}
  end






  # If you want to receive custom messages, they will be delivered
  # to the usual handler for your callback mode with event_type :info
  def handle_event(:info, _event, state, data) do
    {:next_state, state, data}
  end

  def handle_event(event_type, event_content, state, data) do
    # Call the default implementation from GenStateMachine
    super(event_type, event_content, state, data)
  end

end
