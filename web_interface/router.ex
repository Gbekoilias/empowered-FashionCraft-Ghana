defmodule MyAppWeb.Router do
  use Phoenix.Router

  # Define pipelines for different request types
  pipeline :browser do
    plug :fetch_session
    plug :accepts, ["html"]
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Scope for browser-related routes
  scope "/", MyAppWeb do
    pipe_through :browser # Use the browser pipeline

    # Define routes for pages
    get "/", PageController, :index
    get "/about", PageController, :about
    get "/contact", PageController, :contact

    # Define resourceful routes for users
    resources "/users", UserController, only: [:index, :show, :new, :create]
  end

  # Scope for API-related routes
  scope "/api", MyAppWeb do
    pipe_through :api # Use the API pipeline

    # Define API routes for users
    resources "/users", Api.UserController, only: [:index, :show, :create]
  end

  # Catch-all route for unmatched paths (optional)
  match "*path", PageController, :not_found, via: :all
end
