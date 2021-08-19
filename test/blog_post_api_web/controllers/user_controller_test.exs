defmodule BlogPostApiWeb.UserControllerTest do
  use BlogPostApiWeb.ConnCase
  alias BlogPostApi.Accounts
  alias BlogPostApi.Factory

  describe "POST /user" do
    test "success: register a user and returns it auth token", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), Factory.string_params_for(:user))
      assert %{"token" => _token} = json_response(conn, 201)
    end

    test "error: try to register with invalid data and receives a error message", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), Factory.string_params_for(:invalid_user))
      assert %{"message" => _} = json_response(conn, 400)
    end

    test "error: try to register user with invalid email(already used)", %{conn: conn} do
      {:ok, existent_user} = Accounts.create_user(Factory.string_params_for(:user))

      conn =
        post(
          conn,
          Routes.user_path(conn, :create),
          Factory.string_params_for(:user, email: existent_user.email)
        )

      assert %{"message" => _} = json_response(conn, 409)
    end
  end

  describe "GET /post/paginate/:page_number" do
    setup [:create_user, :conn_with_token]

    setup do
      users = Factory.insert_list(49, :user)
      %{users: users}
    end

    test "success: lists users with pagination", %{conn_with_token: conn_with_token} do
      assert %{
               "has_next" => true,
               "has_prev" => false,
               "count" => 50,
               "next_page" => 2,
               "prev_page" => 0,
               "entries" => [
                 %{
                   "display_name" => _,
                   "email" => _,
                   "id" => _,
                   "image" => _
                 }
                 | _
               ]
             } =
               conn_with_token
               |> get(Routes.user_path(conn_with_token, :paginate, 1))
               |> json_response(200)
    end
  end

  describe "POST /login" do
    @default_password "my-password"

    setup context do
      {:ok, user} =
        Accounts.create_user(Factory.string_params_for(:user, password: @default_password))

      Map.put(context, :user, user)
    end

    test "success: get valid auth token with valid user credentials", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_path(conn, :login), %{
          email: user.email,
          password: @default_password
        })

      assert %{"token" => _token} = json_response(conn, 200)
    end

    test "error: returns error message when given invalid data", %{conn: conn, user: user} do
      assert %{"message" => _} =
               post(conn, Routes.user_path(conn, :login, %{}))
               |> json_response(400)

      assert %{"message" => _} =
               post(
                 conn,
                 Routes.user_path(conn, :login, %{email: user.email, password: "wrong-password"})
               )
               |> json_response(400)
    end
  end

  describe "PUT /user" do
    setup [:create_user, :conn_with_token]

    test "success: update user data with success", %{
      conn_with_token: conn_with_token,
      user: user
    } do
      update_params = Factory.string_params_for(:user) |> Map.take(["display_name"])

      updated_user =
        put(conn_with_token, Routes.user_path(conn_with_token, :update, update_params))
        |> json_response(200)

      assert updated_user["display_name"] == update_params["display_name"]
      assert updated_user["id"] == user.id
    end

    test "error: receives an error with invalid data", %{conn_with_token: conn_with_token} do
      assert %{"message" => _} =
               put(conn_with_token, Routes.user_path(conn_with_token, :update, %{email: ""}))
               |> json_response(400)
    end
  end

  describe "GET /user" do
    setup [:create_user, :conn_with_token]

    test "success: lists all users", %{conn_with_token: conn_with_token, user: user} do
      expected = [user_view(user)]

      assert expected ==
               get(conn_with_token, Routes.user_path(conn_with_token, :index))
               |> json_response(200)
    end
  end

  describe "GET /user/:id" do
    setup [:create_user, :conn_with_token]

    test "success: return a single user with it valid ID", %{
      conn_with_token: conn_with_token,
      user: user
    } do
      json =
        get(conn_with_token, Routes.user_path(conn_with_token, :show, user))
        |> json_response(200)

      assert json == user_view(user)
    end

    test "error: returns 404 when given invalid ID", %{conn_with_token: conn_with_token} do
      json =
        get(conn_with_token, Routes.user_path(conn_with_token, :show, Faker.UUID.v4()))
        |> json_response(404)

      assert json == %{"message" => "Usuário não existe"}
    end

    test "error: returns 404 when try to access without a valid token", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, Faker.UUID.v4()))
      assert %{"message" => _} = json_response(conn, 401)
    end
  end

  describe "DELETE user/me" do
    setup [:create_user, :conn_with_token]

    test "success: deletes current user", %{conn_with_token: conn_with_token, user: user} do
      assert delete(conn_with_token, Routes.user_path(conn_with_token, :delete))
             |> response(204)

      assert get(conn_with_token, Routes.user_path(conn_with_token, :show, user))
             |> response(404)
    end
  end

  defp user_view(user) do
    %{
      "id" => user.id,
      "display_name" => user.display_name,
      "email" => user.email,
      "image" => user.image
    }
  end
end
