defmodule BlogPostApiWeb.Router do
  use BlogPostApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BlogPostApiWeb do
    pipe_through :api
  end
end
