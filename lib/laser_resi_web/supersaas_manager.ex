defmodule LaserResi.SupersaasManager do
  use GenServer

  @timeout :timer.seconds(180)

  ## Client
  def todays_reservations do
    GenServer.call(__MODULE__, :today)
  end

  def tomorrows_reservations do
    GenServer.call(__MODULE__, :tomorrow)
  end

  ## Server
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init (_) do
    schedule_reservations_update(0)
    {:ok, %{today: {}, tomorrow: {}}}
  end

  def handle_call(:today, _from, state) do
    {:reply, state.today, state}
  end

  def handle_call(:tomorrow, _from, state) do
    {:reply, state.tomorrow, state}
  end

  def handle_info(:update, _state) do
    {:noreply, update_reservations()}
  end


  def update_reservations() do
    today = get(:today)
    tomorrow = get(:tomorrow)
    s = %{today: today, tomorrow: tomorrow}

    schedule_reservations_update()

    LaserResi.ResiChannel.broadcast_update(s)

    s
  end

  def get(w) do
    base = "https://supersaas.com/api/range/373744.json?resource_id=549385"

    url = case w do
      :today ->
        base <> "&today=true"
      :tomorrow ->
        tomorrow = with {:ok, now} <- DateTime.now("America/Los_Angeles") do
                   now |> DateTime.to_date()
                   |> Date.add(1)
        end

        day_after = tomorrow
                    |> Date.add(1)
                    |> Date.to_string()
        base <> "&from=#{tomorrow}&to=#{day_after}"
      _ ->
        base
    end

    headers = [
      "Authorization": "Basic Z2l6bW9jZGE6d211RzY3RGxOMEdRZ3lXV29VWE85dw==",
      "Accept": "Application/json; Charset=utf-8"
    ]
    options = [ssl: [{:versions, [:'tlsv1.2']}]]

    {:ok, response} = HTTPoison.get(url, headers, options)

    %HTTPoison.Response{status_code: 200, body: body} = response

    body
    |> Jason.decode!
    |> Map.get("bookings")

  end

  defp schedule_reservations_update(timeout \\ @timeout) do
    Process.send_after(self(), :update, timeout)
  end
end
