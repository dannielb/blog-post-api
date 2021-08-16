defmodule BlogPostApi.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :display_name, :string
      add :email, :string, size: 50, null: false
      add :password, :string, null: false
      add :image, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
