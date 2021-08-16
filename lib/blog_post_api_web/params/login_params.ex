defmodule BlogPostApiWeb.Params.LoginParams do
  use BlogPostApiWeb, :params

  embedded_schema do
    field(:email, :string)
    field(:password, :string)
  end

  def prepare(params), do: changeset(params) |> apply_action(:insert)

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password])
  end
end
