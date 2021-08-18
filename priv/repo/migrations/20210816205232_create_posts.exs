defmodule BlogPostApi.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :content, :text
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)

      timestamps(inserted_at: :published, updated_at: :updated)
    end

    create index(:posts, [:user_id])
  end
end
