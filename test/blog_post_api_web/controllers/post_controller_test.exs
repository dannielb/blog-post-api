defmodule BlogPostApiWeb.PostControllerTest do
  use BlogPostApiWeb.ConnCase

  alias BlogPostApi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST /post" do
    setup [:create_user, :conn_with_token]

    test "success: register a post with valid data", %{
      conn_with_token: conn_with_token,
      user: %{id: user_id} = _user
    } do
      valid_params = Factory.string_params_for(:post)

      conn_with_token =
        post(conn_with_token, Routes.post_path(conn_with_token, :create), valid_params)

      %{"title" => title, "content" => content} = valid_params

      assert %{
               "id" => _,
               "title" => ^title,
               "content" => ^content,
               "user_id" => ^user_id
             } = json_response(conn_with_token, 201)
    end

    test "error: returns an error when given invalid post data", %{
      conn_with_token: conn_with_token
    } do
      conn_with_token =
        post(
          conn_with_token,
          Routes.post_path(conn_with_token, :create),
          Factory.string_params_for(:invalid_post)
        )

      assert %{"message" => _} = json_response(conn_with_token, 400)
    end

    test "error: returns 401 with tries to register without auth", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), Factory.string_params_for(:post))
      assert json_response(conn, 401)
    end
  end

  describe "GET /post" do
    setup [:create_user, :conn_with_token, :create_post]

    test "success: lists all posts", %{conn_with_token: conn_with_token, post: post, user: user} do
      conn_with_token = get(conn_with_token, Routes.post_path(conn_with_token, :index))
      assert [post_view(post, user)] == json_response(conn_with_token, 200)
    end
  end

  describe "GET /post/:id" do
    setup [:create_user, :conn_with_token, :create_post]

    test "success: shows a post if given a valid id", %{
      conn_with_token: conn_with_token,
      post: post,
      user: user
    } do
      conn_with_token = get(conn_with_token, Routes.post_path(conn_with_token, :show, post))
      assert post_view(post, user) == json_response(conn_with_token, 200)
    end

    test "error: return 404 when given an invalid id", %{conn_with_token: conn_with_token} do
      assert %{"message" => _} =
               get(
                 conn_with_token,
                 Routes.post_path(conn_with_token, :show, Faker.UUID.v4())
               )
               |> json_response(404)
    end
  end

  describe "GET /post/search" do
    setup [:create_user, :conn_with_token]

    setup do
      posts = Factory.insert_list(50, :post)
      %{posts: posts}
    end

    test "success: returns posts based on query", %{
      conn_with_token: conn_with_token,
      posts: posts
    } do
      search_post = Enum.random(posts)

      search_term =
        String.split(search_post.title)
        |> Enum.random()

      results =
        get(conn_with_token, Routes.post_path(conn_with_token, :search, %{"q" => search_term}))
        |> json_response(200)

      search_term = String.downcase(search_term)
      for r <- results do
        title = String.downcase(r["title"])
        content = String.downcase(r["content"])
        assert String.contains?(title, search_term) or  String.contains?(content, search_term)
      end
    end
  end

  describe "DELETE /post" do
    setup [:create_user, :conn_with_token, :create_post]

    test "success: deletes chosen post", %{conn_with_token: conn_with_token, post: post} do
      assert delete(conn_with_token, Routes.post_path(conn_with_token, :delete, post))
             |> response(204)

      assert delete(conn_with_token, Routes.post_path(conn_with_token, :delete, post))
             |> response(404)

      assert get(conn_with_token, Routes.post_path(conn_with_token, :show, post))
             |> response(404)
    end

    test "error: receives an error if tries to delete without be the owner", %{
      conn_with_token: conn_with_token
    } do
      another_user = Factory.insert(:user)
      post = Factory.insert(:post, user: another_user)

      assert delete(conn_with_token, Routes.post_path(conn_with_token, :delete, post))
             |> response(401)
    end
  end

  describe "update post" do
    setup [:create_user, :conn_with_token, :create_post]

    test "success: update post and returns it", %{
      conn_with_token: conn_with_token,
      post: %{id: id} = post
    } do
      %{"title" => title, "content" => content} = Factory.string_params_for(:post)

      result =
        put(conn_with_token, Routes.post_path(conn_with_token, :update, post), %{
          "title" => title,
          "content" => content
        })
        |> json_response(200)

      assert %{"id" => ^id, "title" => ^title, "content" => ^content} = result
    end

    test "renders errors when data is invalid", %{conn_with_token: conn_with_token, post: post} do
      conn_with_token =
        put(
          conn_with_token,
          Routes.post_path(conn_with_token, :update, post),
          Factory.string_params_for(:invalid_post)
        )

      assert %{"message" => _} = json_response(conn_with_token, 400)
    end
  end

  defp create_post(context) do
    post = Factory.insert(:post, %{user: context.user})
    %{post: post}
  end

  defp post_view(post, user) do
    %{
      "id" => post.id,
      "title" => post.title,
      "content" => post.content,
      "published" => to_string(post.published),
      "updated" => to_string(post.updated),
      "user" => %{
        "id" => user.id,
        "display_name" => user.display_name,
        "email" => user.email,
        "image" => user.image
      }
    }
  end
end
