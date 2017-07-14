defmodule SocialWeb.Comment do
  use SocialWeb.Web, :model

  @primary_key {:id, :string, autogenerate: false}
  schema "comments" do
    field :user_name,           :string
    field :parent_id,           :string
    field :lever,               :integer
    field :message,             :string
    field :attachments,         :string
    field :like_count,          :integer
    field :comment_count,       :integer
    field :created_time,        Ecto.DateTime
    belongs_to :user, SocialWeb.User, type: :string
    belongs_to :post, SocialWeb.Post, type: :string

    timestamps
  end
end
