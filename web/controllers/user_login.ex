defmodule SocialWeb.UserLogin do
  use SocialWeb.Web, :controller
  alias SocialWeb.{Tools}
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
end
