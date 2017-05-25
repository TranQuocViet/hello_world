defmodule HelloWorld.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :is_admin, :boolean
      add :access_token, :string
      add :paging, :map
      # add :
    end
  end
end
