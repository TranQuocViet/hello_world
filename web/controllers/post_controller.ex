defmodule SocialWeb.PostController do
  use SocialWeb.Web, :controller
  # alias Phoenix.Channel
  alias SocialWeb.{ Tools, Repo, Post, Comment }
  import Ecto.Query, only: [from: 2]

  def index(conn, params) do
    offset = params["count"] || 0
    posts = Repo.all(from(p in Post, limit: 30, offset: ^offset , order_by: [desc: p.created_time])) # lấy posts
    |> Enum.map(fn(post) ->
      Map.take(post, [:id, :user_id, :user_name, :message, :full_picture, :like_count, :comment_count, :link, :created_time, :tag])
    end)

    posts_with_comments = Enum.into(posts, [], fn post -> #lấy comment của post

      post_id = post.id
      comments = Repo.all(from(c in Comment, where: c.post_id == ^post_id, limit: 5))
      |> Enum.map(fn comment ->
        content = Map.take(comment, [:id, :user_id, :user_name, :message])
        comment_id = comment.id
        child_comments = Repo.all(from(c in Comment, where: c.parent_id == ^comment_id, limit: 2))
        |> Enum.map(fn child_comment ->
            Map.take(child_comment, [:id, :user_id, :user_name, :message])
          end)
        %{content: content, child_comment: child_comments}
       end)

      %{post: post, comments: comments}
    end)

    # data = %{post: post, %{comment: comment}}
    json conn, %{success: true, data: posts_with_comments}
  end

  def get_comment(conn, params) do
    parent_id = params["parent_id"]
    offset = params["offset"]
    comments = Repo.all(from(c in Comment, where: c.parent_id == ^parent_id, offset: ^offset))
  end

  def get_post_by_tag(conn, params) do
    # 0: chưa phan loai
    # 1: mới nhất
    # 2: hot nhất
    tag_code = params["tag_code"]
    posts = case tag_code do
      "0" ->
        IO.inspect "0"
      "1" ->
        Repo.all(from(p in Post, order_by: [desc: p.created_time], limit: 5))
        |> Enum.map(fn(post) ->
          Map.take(post, [:id, :user_id, :user_name, :message, :full_picture, :like_count, :comment_count, :link, :created_time])
        end)
      "2" ->
        post_s = Repo.all(from(p in Post, order_by: [desc: p.trust_hot], limit: 3))
        post_s_id = Enum.map(post_s, fn(post) ->
          if post.tag != 2 do
            Ecto.Changeset.change(post, %{tag: 2})
            |> Repo.update
          end
          post.id
        end)
        Repo.all(from(p in Post, where: p.tag == 2, where: not p.id in ^post_s_id)) #thay đổi các post hot cũ thành tag = 0
        |> Enum.each(fn post ->
          Ecto.Changeset.change(post, %{tag: 0})
          |> Repo.update
        end)
        Enum.map(post_s, fn(post) ->
          Map.take(post, [:id, :user_id, :user_name, :message, :full_picture, :like_count, :comment_count, :link, :created_time, :tag])
        end)
      _ ->
        IO.inspect "ko tìm thấy tag post"
    end

    result_post = Enum.into(posts, [], fn post ->
        %{post: post}
      end
      )
    json conn, %{success: true, data: result_post}
  end

  # def trigger_load do
  #
  # end

  def get_one_post(conn, params) do
    post_id = params["post_id"]
    posts = Repo.get(Post, post_id)
    |> Map.take([:id, :user_id, :user_name, :message, :full_picture, :like_count, :comment_count, :link, :created_time, :tag])
    comments = Repo.all(from(c in Comment, where: c.post_id == ^post_id, order_by: [desc: c.created_time]))
    |> Enum.map(fn(comment) ->
      Map.take(comment, [:id, :user_name, :user_id, :message, :attachments, :like_count, :comment_count])
    end)
    # IO.inspect post
    user_id = case Mix.env() do
      :dev -> "1362834353783843"
      :prod -> "1165749846825629"
      # _ -> "1165749846825629"
    end

    update_comment = %{
      action: "group_post:update_for_post",
      user_id: user_id,
      post_id: post_id
    }
    Tools.enqueue_task(update_comment)
    #đoạn này gửi sang worker để load dữ liệu mới nhất của post
    json conn, %{sucess: true, data: %{posts: posts, comments: comments}}
  end

  def add_tag(conn, params) do
    post_id = params["post_id"]
    tag = params["tag"]
    post = Repo.get(Post, post_id)
    Ecto.Changeset.change(post, %{tag: tag})
    |> Repo.update
  end

end
