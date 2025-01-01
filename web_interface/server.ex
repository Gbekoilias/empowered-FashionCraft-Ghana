defmodule TrainingServer do
  use Phoenix.Router
  use Phoenix.Endpoint, otp_app: :training_app

  # Pipeline for browser requests
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # Pipeline for API requests
  pipeline :api do
    plug :accepts, ["json"]
    plug TrainingServer.Auth.Pipeline
  end

  scope "/", TrainingServer do
    pipe_through :browser

    get "/", PageController, :index
    resources "/sessions", SessionController
    resources "/participants", ParticipantController
  end

  scope "/api", TrainingServer.API do
    pipe_through :api

    resources "/training", TrainingController, except: [:new, :edit]
    resources "/schedules", ScheduleController, except: [:new, :edit]
    get "/metrics", MetricsController, :index
  end

  # Endpoint configuration
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected PORT environment variable"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end

# Configuration file (config/config.exs)
import Config

config :training_app, TrainingServer,
  url: [host: "localhost"],
  secret_key_base: "your_secret_key_base",
  render_errors: [view: TrainingServer.ErrorView, accepts: ~w(html json)],
  pubsub_server: TrainingServer.PubSub

config :training_app, TrainingServer.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Error View
defmodule TrainingServer.ErrorView do
  use Phoenix.View, root: "lib/training_server/templates"

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end

# Auth Pipeline
defmodule TrainingServer.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :training_app,
    module: TrainingServer.Guardian,
    error_handler: TrainingServer.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
