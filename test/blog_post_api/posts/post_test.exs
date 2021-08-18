defmodule BlogPostApi.Accounts.PostTest do
  use BlogPostApi.DataCase

  alias BlogPostApi.Posts.Post

  @expected_fields_with_types [
    {:id, :binary_id},
    {:title, :string},
    {:content, :string},
    {:user_id, :binary_id},
    {:published, :naive_datetime},
    {:updated, :naive_datetime}
  ]

  @optional_for_creation [:id, :published, :updated]
  @forbidden_update_fields [:id, :published, :updated]
  @update_fields_with_types for {field, type} <- @expected_fields_with_types,
                                field not in @forbidden_update_fields,
                                do: {field, type}

  describe "fields and types" do
    @tag :schema_definition
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Post.__schema__(:fields) do
          type = Post.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "create_changeset/1" do
    setup do
      user = Factory.insert(:user)
      %{user: user}
    end

    test "success: returns a valid changeset when given valid arguments", %{user: user} do
      valid_params = Factory.string_params_for(:post, %{user_id: user.id})

      changeset = Post.create_changeset(valid_params)
      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @expected_fields_with_types do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected,
               "Value did not match for field: #{field}\nexpected: #{inspect(expected)}\n actual: #{
                 inspect(actual)
               }"
      end
    end

    test "error: returns error changeset when given un-castable values" do
      invalid_params = Factory.string_params_for(:invalid_post)

      assert %Changeset{valid?: false, errors: errors} = Post.create_changeset(invalid_params)

      for {field, _} <- @expected_fields_with_types, field not in @optional_for_creation do
        assert errors[field], "The field :#{field} is missing from errors."
        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "The validation type for #{field}, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = Post.create_changeset(params)

      for {field, _} <- @expected_fields_with_types, field not in @optional_for_creation do
        assert errors[field], "The field :#{field} is missing from errors."
        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end
  end

  describe "update_changeset/1" do
    setup do
      post = Factory.insert(:post)
      %{post: post}
    end

    test "success: returns a valid changeset when given valid arguments", %{
      post: post
    } do
      valid_params = Factory.string_params_for(:post)
      changeset = Post.update_changeset(post, valid_params)
      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @update_fields_with_types do
        assert Map.get(changes, field) == valid_params[Atom.to_string(field)]
      end
    end

    test "error: returns an error changeset when given un-castable values", %{
      post: post
    } do
      invalid_params = Factory.string_params_for(:invalid_post)

      assert %Changeset{valid?: false, errors: errors} =
               Post.update_changeset(post, invalid_params)

      for {field, _} <- @update_fields_with_types do
        assert errors[field], "The field :#{field} is missing from errors."
        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end
  end
end
