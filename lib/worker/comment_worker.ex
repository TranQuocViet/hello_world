defmodule SocialWeb.Worker.CommentWorker do
  alias SocialWeb.{ Repo, FB, Tools, User, Post, Comment }
  import Ecto.Query, only: [from: 2]

  @token "EAAYqPb8KTFcBAEOVDLZBrn0fhfB0Utlz0ziTC3p92Mg3PTJvT0jWde5DjZBBWk8uYRgmAoERMoIR3CVvS3HvHmOnDPQiP5mVuI8zZCgx1aTCe92RT2Oz87kZAE4abwLAcBp3Czn0iEGKA1A1ghizR8uDvCRPUfHMaZAjJbONrK5xsGlovsL1fWzIm7Pd5U0wZD"
  @post_fields ""
  def update_comment(obj) do
    %{
      "user_id" => user_id
    } = obj
  end

  def add_comment() do

  end
end
