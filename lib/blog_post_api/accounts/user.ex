defmodule BlogPostApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts type: :utc_datetime_usec
  @primary_key {:id, :binary_id, autogenerate: true}

  @optional_create_fields [:id, :image, :inserted_at, :updated_at]
  @forbidden_update_fields [:id, :inserted_at, :updated_at]

  schema "users" do
    field :display_name, :string
    field :email, :string
    field :password, :string
    field :image, :string

    timestamps()
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, all_fields())
    |> validate_required(all_fields() -- @optional_create_fields)
    |> validate_length(:display_name, min: 8)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email, message: "Usuário ja cadastrado.")
    |> validate_format(:email, ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i, message: "must be a valid email")
    |> hash_password()
  end

  def update_changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, all_fields() -- @forbidden_update_fields)
    |> validate_required(all_fields() -- @optional_create_fields)
    |> validate_length(:display_name, min: 8)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i)
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, %{password: Bcrypt.hash_pwd_salt(password)})
  end

  defp hash_password(changeset), do: changeset
end
