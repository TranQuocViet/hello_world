defmodule SocialWeb.Repo.Migrations.ChangeColumnMessageOfCommentTypeVarcharToText do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      modify :message, :text
    end
  end
end
