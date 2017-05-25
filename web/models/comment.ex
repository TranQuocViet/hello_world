defmodule HelloWorld.Comment do
  use HelloWorld.Web, :model

  @primary_key {:id, :string, autogenerate: false}
  schema "comments" do
    field :user_name,           :string
    field :parent_id,           :string
    field :message,             :string
    field :attachments,         :string
    belongs_to :user, HelloWorld.User, type: :string
    belongs_to :post, HelloWorld.Post, type: :string
  end
end
