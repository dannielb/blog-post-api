defmodule BlogPostApi.AccountsTest do
  use BlogPostApi.DataCase

  alias BlogPostApi.Accounts
  alias BlogPostApi.Accounts.User

  describe "create/1" do
    test "success: it inserts a user in the db and returns the user" do
      params = Factory.string_params_for(:user)
      assert {:ok, %User{} = returned_user} = Accounts.create_user(params)
      user_from_db = Repo.get(User, returned_user.id)

      mutated = ["password"]

      for {param_field, expected} <- params, param_field not in mutated do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(user_from_db, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{
                 inspect(actual)
               }"
      end

      assert Bcrypt.verify_pass(params["password"], user_from_db.password)

      assert user_from_db.inserted_at == user_from_db.updated_at
    end

    test "error: returns an error tuple when user can't be created" do
      bad_params = %{}
      assert {:error, %Changeset{valid?: false}} = Accounts.create_user(bad_params)
    end
  end

  describe "get_user/1" do
    test "success: it returns a user when given a valid UUID" do
      existing_user = Factory.insert(:user)
      assert {:ok, _returned_user} = Accounts.get_user(existing_user.id)
    end

    test "error: it returns an error tuple when a user doesn't exist" do
      assert {:error, :not_found} = Accounts.get_user(Ecto.UUID.generate())
    end
  end

  describe "update_user/2" do
    test "success: it updates database and returns the updated user" do
      existing_user = Factory.insert(:user)

      params =
        Factory.string_params_for(:user)
        |> Map.take(["display_name"])

      assert {:ok, returned_user} = Accounts.update_user(existing_user, params)

      user_from_db = Repo.get(User, returned_user.id)

      expected_user_data =
        existing_user
        |> Map.from_struct()
        |> Map.drop([:__meta__, :inserted_at, :updated_at])
        |> Map.put(:display_name, params["display_name"])

      for {field, expected} <- expected_user_data do
        actual = Map.get(user_from_db, field)

        assert actual == expected, "Values mismatch on update, field: #{field} \n
          expected: #{expected} \n
          actual: #{actual}"
      end

      refute user_from_db.updated_at == existing_user.updated_at
    end

    test "error: returns an error tuple when user can't be updated" do
      existing_user = Factory.insert(:user)
      bad_params = %{"email" => nil}

      assert {:error, %Changeset{}} = Accounts.update_user(existing_user, bad_params)
    end
  end

  describe "delete/1" do
    test "success: it deletes the user" do
      user = Factory.insert(:user)
      assert {:ok, _} = Accounts.delete_user(user)

      refute Repo.get(User, user.id)
    end
  end
end
