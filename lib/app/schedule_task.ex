defmodule SocialWeb.ScheduledTask do
  # use Quantum.Scheduler, otp_app: :social_web
  alias SocialWeb.{Tools, Repo, Post}
  # import Ecto.Query, only: [from: 2]

  def update_post do
    update_post = %{
      action: "group:update_post",
      user_id: "1165749846825629"
    }
    Tools.enqueue_task(update_post)
  end

  def adjust_trust_hot do
      Repo.update_all(Post, inc: [trust_hot: - 10] )
    # Repo.all(from(p in Post, where: ))
  end
end
