defmodule SocialWeb.Repo.Migrations.Posts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false ) do
     add :id, :text, primary_key: true
     # add :id, :string, size: 128, null: false
     add :user_id, :text
     add :user_name, :text
     add :message, :text
     add :full_picture, :text
     add :attachments, {:array, :map}
     add :like_count, :integer
     add :comment_count, :integer
    #  add :reactions, :map
     add :status_type, :text
     add :type, :text
     add :link, :text
     add :comment_paging, :text
     add :trust_hot, :integer
     add :created_time, :datetime
     add :tag, :integer
     add :type_user, :string
     timestamps
    end

    create index(:posts, [:id])
    create index(:posts, [:trust_hot])
    create index(:posts, ["inserted_at DESC"])
    create index(:posts, ["created_time DESC"])
  end
end
