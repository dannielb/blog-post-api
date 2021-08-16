defmodule BlogPostApiWeb.AuthErrorHandler do
  @moduledoc """
  Handles Guardian's authentication errors
  """
  use BlogPostApiWeb, :controller

  def auth_error(conn, {:unauthenticated, :unauthenticated}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BlogPostApiWeb.AuthView)
    |> render("unauthorized.json", [])
  end

  def auth_error(conn, {:invalid_token, :invalid_token}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BlogPostApiWeb.AuthView)
    |> render("invalid_token.json", [])
  end
end
