defmodule HelloWorld.Post do
  use HelloWorld.Web, :model

  @primary_key {:id, :string, autogenerate: false}
  schema "posts" do
    field :user_name,             :string
    field :message,               :string
    field :link,                  :string
    field :full_picture,          :string
    field :attachments,           {:array, :map}, default: []
    field :like_count,            :integer
    field :comment_count,         :integer
    field :status_type,           :map
    field :type,                  :string
    field :tag,                   :integer, default: 0
    field :trust_hot,             :integer, default: 0
    field :created_time,          Ecto.DateTime

    belongs_to :user, HelloWorld.User, type: :string
    has_many :comment, HelloWorld.Comment

    timestamps
  end
end
