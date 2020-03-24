defmodule LaserResi.TimeManager do
  use GenServer

  @timeout :timer.seconds(1)

  ## Client
  def time_now do
    GenServer.call(__MODULE__, :time_now)
  end

  ## Server
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init (_) do
    schedule_time_update(0)
    {:ok, %{clock: ""}}
  end

  def handle_call(:time_now, _from, state) do
    {:reply, state.clock, state}
  end

  def handle_info(:time_adjust, _state) do
    {:noreply, update_time()}
  end

  defp update_time do
    updated_time =
      "US/Pacific"
      |> Timex.now()
      |> Timex.format!("%l:%M:%S %p", :strftime)

    schedule_time_update()

    LaserResi.TimeChannel.broadcast_update(updated_time)

    %{clock: updated_time}
  end

  defp schedule_time_update(timeout \\ @timeout) do
    Process.send_after(self(), :time_adjust, timeout)
  end
end