defmodule HelloWorld.User do
  use HelloWorld.Web, :model

  @primary_key {:id, :string, autogenerate: false}
  schema "users" do
    field :name,              :string
    field :is_admin,          :boolean
    field :access_token,      :string
    field :paging,            :map
  end
end
