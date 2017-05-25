defmodule SocialWeb.Comment do
  use SocialWeb.Web, :model

  @primary_key {:id, :string, autogenerate: false}
  schema "comments" do
    field :user_name,           :string
    field :parent_id,           :string
    field :message,             :string
    field :attachments,         :string
    belongs_to :user, SocialWeb.User, type: :string
    belongs_to :post, SocialWeb.Post, type: :string
  end
end
