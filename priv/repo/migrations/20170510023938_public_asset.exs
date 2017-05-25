defmodule SocialWeb.Repo.Migrations.PublicAsset do
  use Ecto.Migration

  def change do
    create table(:public_asset, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, :string
      add :access_token, :string
      add :post_paging, :map
    end
  end
end
