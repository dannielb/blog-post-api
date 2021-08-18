defmodule BlogPostApiWeb.PostController do
  use BlogPostApiWeb, :controller

  alias BlogPostApi.Guardian
  alias BlogPostApi.Posts
  alias BlogPostApi.Posts.Post

  action_fallback BlogPostApiWeb.FallbackController

  plug :validate_post when action in [:update, :delete]

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def search(conn, %{"q" => term}) do
    posts = Posts.search_post(term)
    render(conn, "index.json", posts: posts)
  end

  def create(conn, post_params) do
    with {:ok, user} <- Guardian.Plug.current_resource(conn),
         post_params <- Map.merge(post_params, %{"user_id" => user.id}),
         {:ok, %Post{} = post} <- Posts.create_post(post_params) do
      conn
      |> put_status(:created)
      |> render("simple_post.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, _uuid} <- Ecto.UUID.cast(id), {:ok, post} <- Posts.get_post(id) do
      render(conn, "show.json", post: post)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render("404.json", [])
    end
  end

  def update(conn, post_params) do
    with {:ok, %Post{} = post} <- Posts.update_post(conn.assigns[:post], post_params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, _params) do
    with {:ok, %Post{}} <- Posts.delete_post(conn.assigns[:post]) do
      send_resp(conn, :no_content, "")
    end
  end

  defp validate_post(conn, _opts) do
    with {:ok, user} <- Guardian.Plug.current_resource(conn),
         {:ok, post} <- Posts.get_post(conn.params["id"]),
         {:ok, _post} <- Posts.is_the_owner?(post, user) do
      conn
      |> assign(:post, post)
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render("404.json", [])
        |> halt()

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(BlogPostApiWeb.AuthView)
        |> render("user_without_privileges.json", [])
        |> halt()
    end
  end
end
