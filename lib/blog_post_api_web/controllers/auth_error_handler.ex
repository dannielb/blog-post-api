defmodule BlogPostApiWeb.AuthErrorHandler do
  @moduledoc """
  Handles Guardian's authentication errors
  """
  use BlogPostApiWeb, :controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {:unauthenticated, :unauthenticated}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BlogPostApiWeb.AuthView)
    |> render("unauthorized.json", [])
  end
end
