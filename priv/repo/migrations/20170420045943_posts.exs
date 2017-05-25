defmodule SocialWeb.Repo.Migrations.Posts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false ) do
     add :id, :string, size: 256, primary_key: true
     # add :id, :string, size: 128, null: false
     add :user_id, :string
     add :user_name, :string
     add :message, :text
     add :full_picture, :string
     add :attachments, {:array, :map}
     add :like_count, :integer
     add :comment_count, :integer
    #  add :reactions, :map
     add :status_type, :string
     add :type, :string
     add :link, :string
     add :comment_paging, :string
     add :trust_hot, :integer
     add :created_time, :datetime
     add :tag, :integer
    #  check :trust_hot,  trust_hot: > 0
     # add :page_id, references(:pages, type: :string, on_delete: :nothing)

     timestamps
    end

  end
end
