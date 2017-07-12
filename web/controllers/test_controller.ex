defmodule SocialWeb.TestController do
  use SocialWeb.Web, :controller
  alias SocialWeb.{ Tools, User, FB }

  def index(conn, _params) do
    user_id = case Mix.env() do
      :dev -> "1362834353783843"
      :prod -> "1165749846825629"
      # _ -> "1165749846825629"
    end
    update_post = %{
      action: "group:update_post",
      user_id: user_id
    }

    Tools.enqueue_task(update_post)

    json conn, %{success: true, data: "gggg"}
  end

  def get_long_live_token(conn, _params) do
    client_id = case Mix.env() do
      :dev -> 1868880940051528
      :prod -> 798953583591937
      _ -> 1868880940051528
    end
    graph_call = %FB.Graph{
      version: "v2.8",
      id: "oauth",
      ref: "access_token",
      custom: %{
        "client_id" => client_id,
        # "client_secret" => "cfcaaea7044d0cb6cd4b416171af2e62",
        "client_secret" => "d44758a616e905dc858961427dbca4c4",
        "grant_type" => "fb_exchange_token",
        "fb_exchange_token" => "EAAajvMCPLEgBAAdJSA6YbKy8hh7WBf20B3n9L7hUBB62j6ZBWeYVNK99W7Rsp3ZB5VZC9a81kjdOn25a7k9nzba0K3vZBym7pGQ6cKyZA7PAnv2SoElcLoZAsBdO1QBqZARs4X1H3mpSKCcx65V51nR6U2DzdbkRl4gArQKZAW2QzyVM3tRup54ZA1E3KtDbH6ZA4ZD"
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
