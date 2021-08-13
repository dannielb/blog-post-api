defmodule BlogPostApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :displayName, :string
    field :email, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:displayName, :email, :password])
    |> validate_required([:displayName, :email, :password])
  end
end
