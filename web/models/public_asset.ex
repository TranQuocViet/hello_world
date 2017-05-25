defmodule SocialWeb.PublicAsset do
  use SocialWeb.Web, :model

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "public_asset" do
    field :access_token, :string
    field :max_trust_hot, :float, default: 0.0
  end
end
