defmodule HelloWorld.Tools do
  # import Plug.Conn
  # import Ecto.Query, only: [from: 2]
  alias HelloWorld.{ Repo, Storage, Post, PublicAsset }
  alias Ecto.DateTime
  import Ecto.Query, only: [from: 2]

  def enqueue_task(task) do
    IO.inspect task
    r_channel = Application.get_env(:hello_world, :r_channel)
    r_queue = System.get_env("R_QUEUE") || "task_pool"
    task_msg = Poison.encode! task
    AMQP.Basic.publish r_channel, "", r_queue, task_msg, persistent: true
  end

  # def http_get(url, err_msg \\ "Không thể thực hiện GET") do
  #   handle_http_response(HTTPoison.get(url, [], [recv_timeout: 45000]), url, err_msg)
  # end

  def http_get(url, err_msg \\ "Không thể thực hiện GET", timeout \\ 45000) do
    handle_http_response(HTTPoison.get(url, [], [recv_timeout: timeout, hackney: [cookie: ["c_user=4"]]]), url, err_msg)
  end

  def http_post(url, data, err_msg \\ "Không thể thực hiện POST") do
    handle_http_response(HTTPoison.post(url, data, [], [recv_timeout: 45000]), url, err_msg)
  end

  def http_delete(url, err_msg \\ "Không thể thực hiện DELETE") do
    handle_http_response(HTTPoison.delete(url, [], [recv_timeout: 45000]), url, err_msg)
  end

  def handle_http_response(response, url, err_msg), do: handle_http_response(response, url, err_msg, 0)
  def handle_http_response(response, url, err_msg, count) do
    case response do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        case Poison.decode body do
          {:ok, response} ->
            is_success = cond do
              status_code >= 200 and status_code < 300 -> true
              true -> false
            end
            %{"success" => is_success, "response" => response}
          {:error, _} ->
            %{"success" => false, "response" => body}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect response
        IO.puts "ERROR URL: #{url}"

        if count < 10 do
          :timer.sleep(10000)
          handle_http_response(response, url, err_msg, count + 1)
        else
          %{
            "success" => false,
            "message" => reason || err_msg
          }
        end
    end
  end
  def parse_fb_time(fb_time) when is_map(fb_time), do: fb_time
  def parse_fb_time(fb_time) do
    String.slice(fb_time, 0..-6)
    |> DateTime.cast!
  end
  def utc_to_vn_time(date_time) do
    gg = date_time |>  Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds
    new_date_time  = gg + 25200
    |> :calendar.gregorian_seconds_to_datetime |> Ecto.DateTime.from_erl
  end
  # def check_post_is_hot(comment_count, like_count, value_is_hot) do
  #   # public_assets = Repo.all(from(a in PublicAsset, limit: 1))
  #   # public_asset = if public_assets == [] do
  #   #   Repo.insert(%PublicAsset{})
  #   # else
  #   #   List.first(public_assets)
  #   # end
  #   current_max_trust_hot = public_asset.max_trust_hot
  #   checking_value = 0.7*comment_count + 0.3*like_count
  #   if checking_value > value_is_hot do
  #     gg = Repo.all(from(p in Post, where: p.trust_hot <= ^checking_value and p.tag == 3))
  #     IO.inspect gg
  #     Enum.each(gg, fn post ->
  #       Ecto.Changeset.change(post, %{tag: 0.0})
  #     end)
  #     3
  #   else
  #     0
  #   end
  # end
end
