defmodule BlogPostApi.Posts.Post do
  @moduledoc false
  use BlogPostApi.Schema
  alias BlogPostApi.Accounts.User

  @forbidden_update_fields ~w(id published updated)a

  schema "posts" do
    field :content, :string
    field :title, :string

    belongs_to :user, User
    timestamps(inserted_at: :published, updated_at: :updated)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields) -- @forbidden_update_fields
  end

  def create_changeset(attrs), do: changeset(%__MODULE__{}, attrs)

  def update_changeset(%__MODULE__{} = post, attrs), do: changeset(post, attrs)

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, all_fields())
    |> cast_assoc(:user)
    |> validate_required(all_fields())
  end
end
