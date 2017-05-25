defmodule SocialWeb.Repo.Migrations.CreateTableComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :string, primary_key: true
      add :post_id, :string
      add :parent_id, :string
      add :user_id, :string
      add :user_name, :string

      add :message, :string
      add :attachments, :map

    end
  end
end
