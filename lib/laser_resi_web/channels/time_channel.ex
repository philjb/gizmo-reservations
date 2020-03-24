defmodule LaserResi.TimeChannel do
  use LaserResiWeb, :channel

  # Client method called after an update.
  def broadcast_update(time) do
    # Render the template again using the new time.
    html = Phoenix.View.render_to_string(
      LaserResiWeb.ClockView,
      "clock.html",
      [time_now: time]
    )

    # Send the updated HTML to subscribers.
    LaserResiWeb.Endpoint.broadcast(
      "time:now",
      "update",
      %{html: html}
    )
  end

  # Called in `app.js` to subscribe to the Channel.
  def join("time:now", _params, socket) do
    {:ok, socket}
  end
end