defmodule LaserResi.ResiChannel do
  use LaserResiWeb, :channel


  # Client method called after an update.
  def broadcast_update(reservations) do
    # Render the template again using the new reservations.

    html_today = Phoenix.View.render_to_string(
      LaserResiWeb.LaserReservationView,
      "reservations.html",
      [reservations: reservations.today]
    )

    html_tomorrow = Phoenix.View.render_to_string(
      LaserResiWeb.LaserReservationView,
      "reservations.html",
      [reservations: reservations.tomorrow]
    )

    # Send the updated HTML to subscribers.
    LaserResiWeb.Endpoint.broadcast(
      "resi:update",
      "today",
      %{html: html_today}
    )

    # Send the updated HTML to subscribers.
    LaserResiWeb.Endpoint.broadcast(
      "resi:update",
      "tomorrow",
      %{html: html_tomorrow}
    )
  end

  # Called in `app.js` to subscribe to the Channel.
  def join("resi:update", _params, socket) do
    {:ok, socket}
  end

end