defmodule LaserResiWeb.Router do
  use LaserResiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LaserResiWeb do
    pipe_through :browser

    get "/laser_reservations", LaserReservationController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", LaserResiWeb do
  #   pipe_through :api
  # end
end
