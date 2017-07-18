  defmodule SocialWeb.ScheduledTask do
  # use Quantum.Scheduler, otp_app: :social_web
  alias SocialWeb.{Tools, Repo, Post, User, FB}
  import Ecto.Query, only: [from: 2]

  def update_post do
    if list_admin = Repo.all(from(u in User, select: u)) do
      admin_user = list_admin |> Enum.map(fn(user) ->
        Map.take(user, [:id, :name, :access_token, :paging, :is_admin])
      end)
      |> Enum.random
      update_post = %{
        action: "group:update_post",
        user_id: admin_user.id
      }
      Tools.enqueue_task(update_post)
    else
      IO.inspect "Schedule Task ko tìm thấy admin nào"
    end
    # admin_user = Repo.all(from(u in User, select: u))
    # |>
  end

  def check_expire_access_token do
    admin_users = Repo.all(from(u in User, select: u))
    |> Enum.map(fn(user) ->
      token = user.access_token
      # IO.inspect token
      graph_call = %FB.Graph{
          id: user.id,
          # ref: user.id,
          access_token: token,
          custom: %{
            "access_token" => token
          },
          version: "v2.9"
        }
        |> FB.graph_get
      if graph_call["success"] do
        Ecto.Changeset.change(user, %{token_id_available: true})
        |> Repo.update
      else
        Ecto.Changeset.change(user, %{token_id_available: false})
        |> Repo.update
      end
     end)
  end

  def adjust_trust_hot do
      Repo.update_all(Post, inc: [trust_hot: - 10] )
    # Repo.all(from(p in Post, where: ))
  end
end
