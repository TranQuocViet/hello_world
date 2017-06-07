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

  def get_long_live_token(conn, _params) do
    graph_call = %FB.Graph{
      version: "v2.8",
      id: "oauth",
      ref: "access_token",
      custom: %{
        "client_id" => 798953583591937,
        "client_secret" => "cfcaaea7044d0cb6cd4b416171af2e62",
        "grant_type" => "fb_exchange_token",
        "fb_exchange_token" => "EAAYoqR63mBEBAMVt87yvIN6kFUGqnoMxamAic5DUtFLg4bYU9jQBQxxJIyUaWTJxy9ZCMa8waHZBT9UiTrzN0IeX1PlNWnExbrU13djks92TyFLiz7WAWwmwbJSZBigkLgW7KZCLnNUetSx4I449iYnjrSa6uAfNgBjvOB2gp0p6Talj4FpETtPdRoqYTsFcEUnw8dqEFAZDZD"
      }
    }
    |> FB.graph_get
    |> IO.inspect

    if graph_call["success"] do
      access_token = graph_call["response"]["access_token"]
      |> IO.inspect
      # handle_token_exchanged(conn, access_token)
    # else
    #   response = graph_call["response"]
    #   message = response["error"]["message"]
    #   Tools.json_error(conn, message, 400, 106)
    end
    json conn, %{success: true, data: "get_token_success"}
  end

end
