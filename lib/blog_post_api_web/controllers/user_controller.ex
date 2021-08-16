defmodule BlogPostApiWeb.UserController do
  use BlogPostApiWeb, :controller

  alias BlogPostApi.Accounts
  alias BlogPostApi.Accounts.User
  alias BlogPostApi.Guardian
  alias BlogPostApiWeb.Params.LoginParams

  action_fallback BlogPostApiWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("token.json", %{token: token})
    end
  end

  def login(conn, params) do
    with {:ok, params} <- LoginParams.prepare(params),
         {:ok, user} <- Accounts.get_user_by_credentials(params.email, params.password),
         {:ok, token, _} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:ok)
      |> render("token.json", %{token: token})
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, _uuid} <- Ecto.UUID.cast(id), {:ok, user} <- Accounts.get_user(id) do
      render(conn, "show.json", user: user)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render("404.json", [])
    end
  end

  def delete(conn, _) do
    with {:ok, user} <- Guardian.Plug.current_resource(conn), {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
