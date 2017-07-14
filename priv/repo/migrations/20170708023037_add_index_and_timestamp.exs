defmodule SocialWeb.Repo.Migrations.AddIndexAndTimestamp do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :created_time, :datetime
      add :like_count, :integer
      add :comment_count, :integer
      add :lever, :integer
      timestamps default: "2016-01-01 00:00:01"
    end

    alter table(:posts) do
      add :type_user, :string
    end

    create index(:posts, [:id])
    create index(:posts, ["inserted_at DESC"])
    create index(:comments, [:id])
    create index(:comments, [:post_id])
    create index(:comments, ["inserted_at DESC"])
  end
end
