defmodule SocialWeb.Repo.Migrations.ChangeAllVarcharToText do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :id, :text
      modify :user_id, :text
      modify :status_type, :text
      modify :type, :text
    end

    alter table(:comments) do
      modify :id, :text
      modify :post_id, :text
      modify :parent_id, :text
      modify :user_id, :text
      modify :user_name, :text
    end
  end
end
