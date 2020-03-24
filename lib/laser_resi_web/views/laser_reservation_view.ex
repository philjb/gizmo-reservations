defmodule LaserResiWeb.LaserReservationView do
  use LaserResiWeb, :view


  defp now do
    {:ok, now} = DateTime.now("America/Los_Angeles")
    now
  end

  def today do
    d = now() |> day_display()
    d <> " " <> (now() |> DateTime.to_date() |> Date.to_string())
  end

  def tomorrow do
    now() |> DateTime.add(24*60*60, :second) |> day_display()
  end

  defp day_display(d) do
    day_of_week(Date.day_of_week(DateTime.to_date(d)))
  end


  defp day_of_week(num) do
    days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ]

    Enum.at(days, num - 1)
  end


  defp parse_date(s) do
    {:ok, date} = Timex.parse(s, "{ISO:Extended}")
    date |> Timex.format!("%l:%M %p", :strftime)
  end

  def time_now_html do
    # read time now for page load
    time_now = LaserResi.TimeManager.time_now()

    Phoenix.View.render(
      LaserResiWeb.ClockView,
      "clock.html",
      [time_now: time_now]
    )

  end

  def today_reservations_html do
    # read time now for page load
    todays = LaserResi.SupersaasManager.todays_reservations()

    Phoenix.View.render(
      LaserResiWeb.LaserReservationView,
      "reservations.html",
      [reservations: todays]
    )
  end

  def tomorrow_reservations_html do
    # read time now for page load
    tomorrows = LaserResi.SupersaasManager.tomorrows_reservations()

    Phoenix.View.render(
      LaserResiWeb.LaserReservationView,
      "reservations.html",
      [reservations: tomorrows]
    )
  end

end
