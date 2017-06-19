defmodule SocialWeb.UserController do
  use SocialWeb.Web, :controller
  alias SocialWeb.{Tools, FB, User}
  import Ecto.Query, only: [from: 2]

  # @group_id System.get_env("GROUP_ID") || "101895420341772"
  @group_id System.get_env("GROUP_ID") || "235583826938860"


  def index(conn, _params) do
    admins = Repo.all(from(u in User, select: u))
    |> Enum.map(fn(user) ->
      Map.take(user, [:id, :name, :token_id_available])
    end)
    json conn, %{admins: admins}
  end
  def login_and_sync_data(conn, params) do
    short_access_token = params["short_access_token"]
    IO.inspect short_access_token
    user_id = params["user_id"]

    if admin_user = Repo.get(User, user_id) do
      long_live_token = FB.generate_long_live_access_token(short_access_token)
      if long_live_token do
        Ecto.Changeset.change(admin_user, %{access_token: long_live_token, is_admin: true})
        |> Repo.update

        update_post = %{
          action: "group:update_post",
          user_id: user_id
        }
        Tools.enqueue_task(update_post)
        json conn, %{success: true}
      else
        json conn, %{success: false, message: "Xảy ra lỗi khi gọi fb API"}
      end
    else #khong tim thay tk trong db
      # graph_call = %FB.Graph{
      #   id: user_id,
      #   ref: "groups",
      #   fields: "administrator",
      #   access_token: short_access_token,
      #   version: "2.9"
      # }
      # |> FB.graph_get
      # if graph_call["success"] do
      #   data = graph_call["data"]
      #   gg = Enum.find(data, fn group ->
      #     ((group["id"] == @group_id) && (group["administrator"] == true))
      #   end)
      # end
      json conn, %{success: false, message: "Không tìm thấy tài khoản admin này trong db" }
    end

  end

  def new_admin(conn, params) do
    user_id = params["user_id"]
    short_access_token = params["access_token_login"]
    if admin = Repo.get(User, user_id) do
      json conn, %{message: "Tài khoản admin đã tồn tại"}
    else
      graph_call = %FB.Graph{
        id: user_id,
        ref: "groups",
        fields: "moderator",
        access_token: short_access_token,
        version: "v2.9"
      }
      |> FB.graph_get
      |> IO.inspect
      if graph_call["success"] do
        data = graph_call["response"]["data"]
        have_pancake_group = Enum.find(data, fn group ->
          group["id"] == @group_id
        end)
        if have_pancake_group do
          IO.inspect have_pancake_group
          long_live_token = FB.generate_long_live_access_token(short_access_token)
          user_info = %FB.Graph{
            id: user_id,
            access_token: long_live_token,
            version: "v2.9"
          } |> FB.graph_get |> IO.inspect
          user_name = if user_info["success"] do
            user_info["response"]["name"]
          end
          new_admin = %User{
            id: user_id,
            name: user_name,
            is_admin: true,
            access_token: long_live_token,
            token_id_available: true
          }
          |> Repo.insert!
          data_admin = Repo.all(from(u in User, select: u))
          |> Enum.map(fn(user) ->
            Map.take(user, [:id, :name, :token_id_available])
          end)
          json conn, %{data: data_admin}
        else #người dùng ko phải admin
          json conn, %{message: "Bạn ko có quyền admin trên pancake group", logout: true}
        end
      else #
        IO.inspect "API request fail, ko check duoc tai khoan admin"
        json conn, %{message: "Đăng nhập thất bại"}
      end
      # Repo.insert(User, am)
    end
  end

end
