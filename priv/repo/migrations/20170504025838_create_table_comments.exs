defmodule SocialWeb.Repo.Migrations.CreateTableComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :text, primary_key: true
      add :post_id, :text
      add :parent_id, :text
      add :user_id, :text
      add :user_name, :text

      add :message, :text
      add :attachments, :map

      add :created_time, :datetime
      add :like_count, :integer
      add :comment_count, :integer
      add :lever, :integer
      timestamps default: "2016-01-01 00:00:01"
    end

    create index(:comments, [:id])
    create index(:comments, [:post_id])
    create index(:comments, ["inserted_at DESC"])
    create index(:comments, ["created_time DESC"])
  end
end
