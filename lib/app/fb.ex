defmodule HelloWorld.FB do
  alias HelloWorld.Tools
  require Logger

  defmodule Graph do
    @graph_version "v2.6"
    defstruct [
      id: "me",
      ref: nil,
      fields: nil,
      limit: nil,
      include_hidden: nil,
      access_token: nil,
      cursor_after: nil,
      custom: nil,
      version: @graph_version
    ]
  end

  defmodule Page do
    defstruct [
      page_id: "me",
      access_token: nil,
      sync_since: nil,
      sync_util: nil,
      current_page: nil,
      current_post: nil,
      current_conv: nil,
      message_id: nil,
      post_paging: nil,
      is_parent_hidden: false,
      is_automated_reply: false,
      repo: nil,
      origin: nil
    ]
  end

  def graph(params) do
    %Graph{
      id: id,
      ref: ref,
      fields: fields,
      limit: limit,
      include_hidden: include_hidden,
      access_token: access_token,
      version: version,
      cursor_after: cursor_after,
      custom: custom
    } = params

    base_url = if ref == "messages" && String.contains?(id, "/") do
      custom = if custom, do: Map.put(custom, "id", id), else: %{"id" => id}

      "https://graph.facebook.com/#{version}"
    else
      "https://graph.facebook.com/#{version}/#{id}"
    end

    base_url
      |> add_ref(ref)
      |> add_fields_and_token(fields, access_token)
      |> add_limit(limit)
      |> add_include_hidden(include_hidden)
      |> add_cursor(cursor_after)
      |> add_custom(custom)
  end

  def graph_get(params) do
    graph(params)
    |> Tools.http_get
  end

  def graph_post(params, data \\ "") do
    graph(params)
    |> Tools.http_post(data)
  end

  def graph_delete(params) do
    graph(params)
    |> Tools.http_delete
  end

  def handle_graph_error(response, _origin_object) do
    Logger.error "GRAPH ERROR: #{response}"
  end

  defp add_ref(base_url, ref) do
    case ref do
      nil -> base_url
      _ -> base_url <> "/#{ref}"
    end
  end

  defp add_fields_and_token(base_url, fields, access_token) do
    case fields do
      nil -> base_url <> "?access_token=#{access_token}"
      _ -> base_url <> "?fields=#{fields}&access_token=#{access_token}"
    end
  end

  defp add_limit(base_url, limit) do
    case limit do
      nil -> base_url
      _ -> base_url <> "&limit=#{limit}"
    end
  end

  defp add_include_hidden(base_url, include_hidden) do
    case include_hidden do
      nil -> base_url
      _ -> base_url <> "&include_hidden=#{include_hidden}"
    end
  end

  defp add_cursor(base_url, cursor_after) do
    case cursor_after do
      nil -> base_url
      _ -> base_url <> "&after=#{cursor_after}"
    end
  end

  defp add_custom(base_url, custom) do
    case custom do
      nil -> base_url
      _ -> base_url <> Enum.reduce(custom, "", fn({key, value}, acc) -> "#{acc}&#{key}=#{value}" end)
    end
  end

  def safe_facebook_error_response(response) do
    if is_binary(response) do
      if String.contains?(response, ["<title>Facebook | Error</title>", "Sorry, something went wrong.", "We're working on it and we'll get it fixed as soon as we can."]) do
        %{
          "code" => 2,
          "type" => "OAuthException",
          "message" => "Sorry, something went wrong. We're working on it and we'll get it fixed as soon as we can."
        }
      else
        response["error"]
      end
    else
      response["error"]
    end
  end
end
