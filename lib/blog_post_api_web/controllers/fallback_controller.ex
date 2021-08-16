defmodule BlogPostApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BlogPostApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{valid?: false, errors: errors}}) do
    {field, opts} = List.first(errors)

    status_code =
      case opts do
        {_, [constraint: :unique, constraint_name: _]} -> :conflict
        _ -> :bad_request
      end

    conn
    |> put_status(status_code)
    |> put_view(BlogPostApiWeb.ChangesetView)
    |> render("error.json", %{error: {field, opts}})
  end

  def call(conn, {:error, :invalid_data}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogPostApiWeb.ErrorView)
    |> render("error.json", %{error: "Campos invalidos"})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BlogPostApiWeb.ErrorView)
    |> render(:"404")
  end
end
