defmodule BlogPostApi.Accounts.User do
  @moduledoc false
  use BlogPostApi.Schema

  @optional_fields ~w(display_name image)a
  @forbidden_update_fields ~w(id inserted_at updated_at)a

  schema "users" do
    field :display_name, :string
    field :email, :string
    field :password, :string
    field :image, :string

    timestamps()
  end

  defp all_fields do
    __MODULE__.__schema__(:fields) -- @forbidden_update_fields
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def update_changeset(%__MODULE__{} = user, attrs) do
    user
    |> changeset(attrs)
  end

  def changeset(changeset, attrs) do
    changeset
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optional_fields)
    |> validate_length(:display_name, min: 8)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email, message: "Usuário ja existe")
    |> validate_format(:email, ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i,
      message: "must be a valid email"
    )
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, %{password: Bcrypt.hash_pwd_salt(password)})
  end

  defp hash_password(changeset), do: changeset
end
