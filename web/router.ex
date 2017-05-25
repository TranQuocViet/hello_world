defmodule SocialWeb.Router do
  use SocialWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", SocialWeb do
  #   pipe_through :browser # Use the default browser stack
  #
  #   get "/", PageController, :index
  # end

  scope "/api", SocialWeb do
    pipe_through :api
    scope "/gggg" do
      get "/", TestController, :index
    end

    get "/login", UserLogin, :user_login
    scope "/posts" do
      get "/", PostController, :index
      scope "/:tag_code" do
        get "/", PostController, :get_post_by_tag
      end
    end
  end
  # Other scopes may use custom stacks.
  # scope "/api", SocialWeb do
  #   pipe_through :api
  # end
end
