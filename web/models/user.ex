defmodule SocialWeb.User do
  use SocialWeb.Web, :model

  @primary_key {:id, :string, autogenerate: false}
  schema "users" do
    field :name,                :string
    field :is_admin,            :boolean
    field :access_token,        :string
    field :token_id_available,  :boolean
    field :paging,              :map
  end
end
