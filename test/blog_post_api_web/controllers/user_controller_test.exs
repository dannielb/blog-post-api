defmodule BlogPostApiWeb.UserControllerTest do
  use BlogPostApiWeb.ConnCase
  alias BlogPostApi.Factory
  alias BlogPostApi.Accounts
  alias BlogPostApi.Guardian

  describe "POST /user" do
    test "success: register a user and returns it auth token", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), Factory.string_params_for(:user))
      assert %{"token" => _token} = json_response(conn, 201)
    end

    test "error: try to register with invalid data and receives a error message", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), Factory.string_params_for(:invalid_user))
      assert %{"message" => _} = json_response(conn, 400)
    end

    test "error: try to register user with invalid email(already_used)", %{conn: conn} do
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

  describe "GET /user" do
    setup [:create_user]

    test "success: lists all users", %{conn: conn, user: user} do
      expected = [user_view(user)]

      assert expected ==
               get(conn, Routes.user_path(conn, :index))
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

      assert json == %{"message" => "Usuário não encontrado"}
    end

    test "error: returns 404 when try to access without a valid token", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, Faker.UUID.v4()))
      assert %{"message" => _} = json_response(conn, 401)
    end
  end

  # describe "update user" do
  #   setup [:create_user]

  #   test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.user_path(conn, :show, id))

  #     assert %{
  #              "id" => id
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete user" do
  #   setup [:create_user]

  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete(conn, Routes.user_path(conn, :delete, user))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.user_path(conn, :show, user))
  #     end
  #   end
  # end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(Factory.string_params_for(:user))
    %{user: user}
  end

  defp conn_with_token(context) do
    {:ok, token, _} = Guardian.encode_and_sign(context.user, %{}, token_type: :access)

    conn_with_token =
      context.conn
      |> put_req_header("authorization", "Bearer " <> token)

    %{conn_with_token: conn_with_token}
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
