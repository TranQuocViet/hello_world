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

  def create_long_live_token(conn, _params) do
    graph_call = %FB.Graph{
      version: "v2.7",
      id: "oauth",
      ref: "access_token",
      custom: %{
        "client_id" => 1868880940051528,
        "client_secret" => "d44758a616e905dc858961427dbca4c4",
        "grant_type" => "fb_exchange_token",
        "fb_exchange_token" => "EAAajvMCPLEgBAI2NHEywZAh1ow3wXehj5VQCH9PL9pZCIqN51YOKYye2RqndqOel4alQrpQ0vvO7kCO8lqW2qCUSlAcJmuzSl5ZCQ7ZAxy3czusB8E8ttUzHEdXMsBRAGCGM7dUZCZBehRDSS2PCPrSyBoPul9paqUicgqSqUZBpElJ3CXoG4HMpjJESgxIgtwZD"
      }
    }
    |> FB.graph_get

    IO.inspect graph_call
    json conn, %{success: true, data: graph_call}
  end
end
