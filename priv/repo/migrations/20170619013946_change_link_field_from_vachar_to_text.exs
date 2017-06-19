defmodule SocialWeb.Repo.Migrations.ChangeLinkFieldFromVacharToText do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :user_name, :text
      modify :full_picture, :text
      modify :link, :text
      modify :comment_paging, :text
    end
  end
end
