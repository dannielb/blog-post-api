defmodule BlogPostApi.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :displayName, :string
      add :email, :string, size: 50
      add :password, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
