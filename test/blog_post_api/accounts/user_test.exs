defmodule BlogPostApi.Accounts.UserTest do
  use BlogPostApi.DataCase
  alias BlogPostApi.Accounts.User

  @expected_fields_with_types [
    {:id, :binary_id},
    {:display_name, :string},
    {:email, :string},
    {:password, :string},
    {:inserted_at, :utc_datetime_usec},
    {:updated_at, :utc_datetime_usec}
  ]

  @optional_for_creation [:id, :inserted_at, :updated_at]
  @forbidden_update_fields [:id, :inserted_at, :updated_at]
  @update_fields_with_types for {field, type} <-
                                  @expected_fields_with_types,
                                field not in @forbidden_update_fields,
                                do: {field, type}

  describe "fields and types" do
    @tag :schema_definition
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- User.__schema__(:fields) do
          type = User.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_with_types) ==
               MapSet.new(@expected_fields_with_types)
    end
  end

  describe "create_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = Factory.string_params_for(:user)

      changeset = User.create_changeset(valid_params)
      assert %Changeset{valid?: true, changes: changes} = changeset
      mutated = [:email, :password]

      for {field, _} <- @expected_fields_with_types, field not in mutated do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected,
               "Value did not match for field: #{field}\nexpected: #{inspect(expected)}\n
               actual: #{inspect(actual)}"
      end

      assert Bcrypt.verify_pass(valid_params["password"], changes.password)
    end

    test "error: returns error changeset when given un-castable values" do
      invalid_params = Factory.string_params_for(:invalid_user)

      assert %Changeset{valid?: false, errors: errors} = User.create_changeset(invalid_params)

      for {field, _} <- @expected_fields_with_types, field not in @optional_for_creation do
        assert errors[field], "The field :#{field} is missing from errors."
        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "The validation type, #{meta[:validation]}, is incorrect."
      end

      for {field, _} <- @optional_for_creation do
        refute errors[field], "The optional field #{field} is required when it shouldn't be."
      end
    end

    test "error: returns error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = User.create_changeset(params)

      for {field, _} <- @expected_fields_with_types, field not in @optional_for_creation do
        assert errors[field], "The field :#{field} is missing from errors."
        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns error changeset when an email address is reused" do
      existing_user = Factory.insert(:user)

      changeset_with_repeated_email =
        Factory.string_params_for(:user)
        |> Map.put("email", existing_user.email)
        |> User.create_changeset()

      assert {:error, %Changeset{valid?: false, errors: errors}} =
               BlogPostApi.Repo.insert(changeset_with_repeated_email)

      assert errors[:email], "The field :email is missing from errors."
      {_, meta} = errors[:email]

      assert meta[:constraint] == :unique,
             "The validation type, #{meta[:validation]}, is incorrect."
    end
  end

  describe "update_changeset/1" do
    setup do
      user = Factory.insert(:user)
      %{user: user}
    end

    test "success: returns a valid changeset when given valid arguments", %{
      user: user
    } do
      valid_params = Factory.string_params_for(:user)
      changeset = User.update_changeset(user, valid_params)
      assert %Changeset{valid?: true, changes: changes} = changeset

      mutated = [:password]

      for {field, _} <- @update_fields_with_types, field not in mutated do
        assert Map.get(changes, field) == valid_params[Atom.to_string(field)]
      end

      assert Bcrypt.verify_pass(valid_params["password"], changes.password)
    end

    test "error: returns an error changeset when given un-castable values", %{
      user: user
    } do
      invalid_params = Factory.string_params_for(:invalid_user)

      assert %Changeset{valid?: false, errors: errors} =
               User.update_changeset(user, invalid_params)

      for {field, _} <- @update_fields_with_types do
        assert errors[field], "The field :#{field} is missing from errors."
        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns error changeset when an email address is reused", %{
      user: user
    } do
      existing_user = Factory.insert(:user)

      params_with_repeated_email =
        Factory.string_params_for(:user)
        |> Map.put("email", existing_user.email)

      changeset_with_repeated_email = User.update_changeset(user, params_with_repeated_email)

      assert {:error, %Changeset{valid?: false, errors: errors}} =
               BlogPostApi.Repo.update(changeset_with_repeated_email)

      assert errors[:email], "The field :email is missing from errors."
      {_, meta} = errors[:email]

      assert meta[:constraint] == :unique,
             "The validation type, #{meta[:validation]}, is incorrect."
    end
  end
end
