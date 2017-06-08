defmodule SocialWeb.UserController do
  use SocialWeb.Web, :controller
  alias SocialWeb.{Tools, FB, User}
  import Ecto.Query, only: [from: 2]
  # def user_login(conn, params) do
  #   redirect_uri = "http://localhost:8000/"
  #   data = [
  #     client_id: 1868880940051528,
  #     redirect_uri: redirect_uri
  #   ]
  #   url = "https://www.facebook.com/v2.9/dialog/oauth"
  #   ggg = Tools.http_post(url, {:form, data})
  #   IO.inspect ggg
  #   json conn, %{success: true, data: ggg}
  # end
  def index(conn, _params) do
    admins = Repo.all(from(u in User, select: u))
    |> Enum.map(fn(user) ->
      Map.take(user, [:id, :name, :token_id_available])
    end)
    json conn, %{admins: admins}
  end
  def login_and_sync_data(conn, params) do
    short_access_token = params["short_access_token"]
    user_id = params["user_id"]

    if admin_user = Repo.get(User, user_id) do
      graph_call = %FB.Graph{
          id: "oauth",
          ref: "access_token",
          custom: %{
            "client_id" => "798953583591937&amp",
            "client_secret" => "cfcaaea7044d0cb6cd4b416171af2e62&amp",
            "grant_type" => "fb_exchange_token&amp",
            "fb_exchange_token" => short_access_token
            },
          version: "v2.9"
        }
        |> FB.graph_get
      long_live_token = if graph_call["success"] do
        graph_call["response"]["access_token"]
      end
      if graph_call["success"] do
        Ecto.Changeset.change(admin_user, %{access_token: long_live_token})
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
    else
      json conn, %{success: false, message: "Không tìm thấy tài khoản admin này" }
    end

  end

end
