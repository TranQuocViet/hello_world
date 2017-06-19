defmodule SocialWeb.Worker.PostWorker do
  alias SocialWeb.{ Repo, FB, Tools, User, Post, Comment }
  import Ecto.Query, only: [from: 2]
  # import Ecto.Repo

  @post_fields "id,message,from,permalink_url,full_picture,created_time,likes,attachments{type,url},comments{id,message,from,attachment,comments{id,message,attachment,from,like_count},comment_count}"
  @group_id System.get_env("GROUP_ID") || "101895420341772"
  def exception() do

  end

  def update_post(obj) do
    %{
      "user_id" => user_id
    } = obj
    if user = Repo.get(User, user_id) do
      case user.paging do
        nil ->
          graph_call = %FB.Graph{
              id: @group_id,
              ref: "feed",
              access_token: user.access_token,
              fields: @post_fields,
              version: "v2.8"
            }
            |> FB.graph_get
            if graph_call["success"] do
              response = graph_call["response"]
              response_data = response["data"]
              if response_data != [] do
                response_paging = response["paging"]
                previous_paging = response_paging["previous"]
                next_paging = %FB.Graph{
                id: @group_id,
                ref: "feed",
                fields: @post_fields,
                version: "v2.8",
                limit: 100,
                access_token: user.access_token
              } |> FB.graph

                Ecto.Changeset.change(user, %{paging: %{"previous" => previous_paging, "next" => next_paging}})
                |> Repo.update!
                sync_post_from_graph(response_data, response_paging, :next, user_id, user.access_token)
              end
            else
              IO.puts "MARKETING API ERROR"
              IO.inspect graph_call
            end
        paging ->
          if paging["next"] do
            graph_call = Tools.http_get paging["next"]
            if graph_call["success"] do
              response = graph_call["response"]
              response_data = response["data"]
              response_paging = response["paging"]
              sync_post_from_graph(response_data, response_paging, :next, user_id, user.access_token)
            else
              IO.puts "MARKETING API ERROR"
              IO.inspect graph_call
            end
          end

          graph_call = Tools.http_get paging["previous"]
          if graph_call["success"] do
            response = graph_call["response"]
            response_data = response["data"]
            response_paging = response["paging"]
            if response_data != [] do
              sync_post_from_graph(response_data, response_paging, :previous, user_id, user.access_token)
            end
          else
            IO.puts "MARKETING API ERROR"
            IO.inspect graph_call
          end
      end
    else
      IO.inspect "ko tim thay user duoc truyen"
    end


  end

  def sync_post_from_graph(response_data, response_paging, direction, user_id, access_token, current_count \\ 0)
  def sync_post_from_graph([], response_paging, direction, user_id, access_token, current_count) do
    user = Repo.get(User, user_id)
    case direction do # luôn có paging (API thế)
      :next ->
        next_paging = response_paging["next"]
        user_paging = Map.put(user.paging, "next", next_paging)
        Ecto.Changeset.change(user, %{last_active_at: Ecto.DateTime.utc, paging: user_paging})
        |> Repo.update!
        if current_count < 300 do
          graph_call = Tools.http_get next_paging
          if graph_call["success"] do
            response = graph_call["response"]
            response_data = response["data"]
            if response_data != [] do
              sync_post_from_graph(response_data, response["paging"], direction, user_id, access_token, current_count)
            else
              user_paging = Map.drop(user.paging, ["next"])
              Ecto.Changeset.change(user, %{last_active_at: Ecto.DateTime.utc, paging: user_paging})
              |> Repo.update!
            end
          else
            IO.puts "MARKETING API ERROR"
            IO.inspect graph_call
          end
        end

      :previous ->
        previous_paging = response_paging["previous"] # luôn trả về paging
        user_paging = Map.put(user.paging, "previous", previous_paging)
        Ecto.Changeset.change(user, %{last_active_at: Ecto.DateTime.utc, paging: user_paging})
        |> Repo.update!
        if current_count < 300 do
          graph_call = Tools.http_get previous_paging
          if graph_call["success"] do
            response = graph_call["response"]
            response_data = response["data"]
            if response_data != [] do
              sync_post_from_graph(response_data, response["paging"], direction, user_id, access_token, current_count)
            end
          else
            IO.puts "MARKETING API ERROR"
            IO.inspect graph_call
          end
        end
    end
  end

  def sync_post_from_graph([post|posts], response_paging, direction, user_id, access_token, current_count) do
    add_post(post, user_id)
    sync_post_from_graph(posts, response_paging, direction, user_id, access_token, current_count + 1)
  end

  def add_post(post, user_id) do
    post_id = post["id"]
    post_attachments = attachment(post)
    like_count = like_count(post)
    comment_count = if comments = post["comments"] do
      data_comment = comments["data"]
      Enum.count(data_comment)
      # insert_comment_count(post)
    else
      0
    end
    trust_hot = 7*comment_count + 3*like_count

    if ((post["message"] != nil) || (post["attachments"] != nil)) && (post["from"]["id"] != nil) do
      # tag = Tools.check_post_is_hot(comment_count, like_count, 2)
      case Repo.get(Post, post_id) do
        nil ->
          new_post = %Post{
            id: post_id,
            message: post["message"],
            link: post["permalink_url"],
            user_id: post["from"]["id"],
            user_name: post["from"]["name"],
            like_count: like_count,
            full_picture: post["full_picture"],
            attachments: post_attachments,
            comment_count: comment_count,
            # tag: tag,
            trust_hot: trust_hot,
            created_time: Tools.parse_fb_time(post["created_time"]) |> Tools.utc_to_vn_time,
            inserted_at: Ecto.DateTime.utc
          } |> Repo.insert!
        existed_post ->
          from(p in Post, where: p.id == ^post_id)
          |> Repo.update_all([set: [
            message: post["message"],
            # tag: tag,
            trust_hot: trust_hot
          ]])
      end
    end

    if comments do
      sync_comment_from_post_graph(data_comment, post_id, post_id)
    end
  end

  def attachment(post) do
    if post_attachments = post["attachments"] do
      data = post_attachments["data"]
      Enum.into(data, [], fn each_attach ->
        type = each_attach["type"]
        url = each_attach["url"]
        %{type: type, url: url}
      end)
    end
  end

  def like_count(post) do
    if likes = post["likes"] do
      like_data = likes["data"]
      Enum.count(like_data)
    else
      0
    end
  end



  def sync_comment_from_post_graph([comment|comments], parent_id, post_id) do
    add_comment(post_id, parent_id, comment)
    sync_comment_from_post_graph(comments, parent_id, post_id)
  end

  def sync_comment_from_post_graph([], parent_id, post_id) do
  end

  def add_comment(post_id, parent_id, comment) do
    comment_id = comment["id"]
    message = comment["message"] || nil
    case Repo.get(Comment, comment_id) do
      nil ->
        new_comment = %Comment{
          id: comment["id"],
          user_id: comment["from"]["id"],
          user_name: comment["from"]["name"],
          post_id: post_id,
          parent_id: parent_id,
          message: comment["message"],
          attachments: comment_media(comment)
        } |> Repo.insert!
      existed_comment ->
        from(c in Comment, where: c.id == ^comment_id)
        |> Repo.update_all([set: [
            message: comment["message"],
            attachments: comment_media(comment)
          ]])
    end




    if comment["comments"] do
      children_comments = comment["comments"]["data"]
      Enum.each(children_comments, fn children_comment ->
        parent_id_of_children = comment["id"]
        add_comment(post_id, parent_id_of_children, children_comment)
      end)
    end
  end

  def comment_media(comment) do
    attachment = comment["attachment"]
    media = attachment["media"]
    src = media["image"]["src"]
  end
end
