  defmodule SocialWeb.ScheduledTask do
  # use Quantum.Scheduler, otp_app: :social_web
  alias SocialWeb.{Tools, Repo, Post, User}
  import Ecto.Query, only: [from: 2]

  def update_post do
    admin_user = Repo.all(from(u in User, select: u))
    |> Enum.map(fn(user) ->
      Map.take(user, [:id, :name, :access_token, :paging, :is_admin])
    end)
    |> Enum.random
    update_post = %{
      action: "group:update_post",
      user_id: admin_user.id
    }
    Tools.enqueue_task(update_post)
  end

  def adjust_trust_hot do
      Repo.update_all(Post, inc: [trust_hot: - 10] )
    # Repo.all(from(p in Post, where: ))
  end
end
