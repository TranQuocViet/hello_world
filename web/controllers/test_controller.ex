defmodule SocialWeb.TestController do
  use SocialWeb.Web, :controller
  alias SocialWeb.{ Tools, User, FB }

  def index(conn, _params) do

    update_post = %{
      action: "group:update_post",
      user_id: "1165749846825629"
    }

    Tools.enqueue_task(update_post)

    json conn, %{success: true, data: "gggg"}
  end

end
