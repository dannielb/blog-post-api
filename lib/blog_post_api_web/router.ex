defmodule BlogPostApiWeb.Router do
  use BlogPostApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug Guardian.Plug.VerifyHeader,
      module: BlogPostApi.Guardian,
      error_handler: BlogPostApiWeb.AuthErrorHandler
  end

  pipeline :ensure_authed_access do
    plug Guardian.Plug.EnsureAuthenticated, error_handler: BlogPostApiWeb.AuthErrorHandler
    plug Guardian.Plug.LoadResource, allow_blank: true, module: BlogPostApi.Guardian
  end

  scope "/", BlogPostApiWeb do
    pipe_through :api
    resources "/user", UserController, only: [:create]
    post "/login", UserController, :login
  end

  scope "/", BlogPostApiWeb do
    pipe_through [:api, :ensure_authed_access]

    resources "/user", UserController, only: [:index, :show]
    get "/user/paginate/:page_number", UserController, :paginate
    put "/user", UserController, :update
    delete "/user/me", UserController, :delete

    get "/post/search", PostController, :search
    get "/post/paginate/:page_number", PostController, :paginate
    resources "/post", PostController, only: [:create, :update, :delete, :show, :index]
  end
end
