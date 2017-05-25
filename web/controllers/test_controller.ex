defmodule HelloWorld.TestController do
  use HelloWorld.Web, :controller
  alias HelloWorld.{ Tools, User }
  def index(conn, params) do

    update_post = %{
      action: "group:update_post",
      user_id: "1165749846825629"
    }

    Tools.enqueue_task(update_post)

    json conn, %{success: true, data: "gggg"}
  end
end
