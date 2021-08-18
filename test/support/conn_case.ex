defmodule BlogPostApiWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use BlogPostApiWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import BlogPostApiWeb.ConnCase

      alias BlogPostApiWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint BlogPostApiWeb.Endpoint

      # Helpers for authentication
      defp create_user(_) do
        {:ok, user} =
          BlogPostApi.Accounts.create_user(BlogPostApi.Factory.string_params_for(:user))

        %{user: user}
      end

      defp conn_with_token(context) do
        {:ok, token, _} =
          BlogPostApi.Guardian.encode_and_sign(context.user, %{}, token_type: :access)

        conn_with_token =
          context.conn
          |> put_req_header("authorization", "Bearer " <> token)

        %{conn_with_token: conn_with_token}
      end
    end
  end

  setup tags do
    :ok = Sandbox.checkout(BlogPostApi.Repo)

    unless tags[:async] do
      Sandbox.mode(BlogPostApi.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
