defmodule BlogPostApiWeb.Router do
  use BlogPostApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, module: BlogPostApi.Guardian
  end

  pipeline :ensure_authed_access do
    plug Guardian.Plug.EnsureAuthenticated, error_handler: BlogPostApiWeb.AuthErrorHandler
  end

  scope "/", BlogPostApiWeb do
    pipe_through :api
    resources "/user", UserController, only: [:index, :create]
    post "/login", UserController, :login
  end

  scope "/", BlogPostApiWeb do
    pipe_through [:api, :ensure_authed_access]
    resources "/user", UserController, only: [:show]
  end
end
