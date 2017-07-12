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

  scope "/", SocialWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", SocialWeb do
    pipe_through :api
    scope "/pull_post" do
      get "/", TestController, :index
    end
    get "/get_token", TestController, :get_long_live_token
    # scope "/create_long_live_token" do
    #   get "/",  TestController, :create_long_live_token
    # end

    # get "/login", UserLogin, :user_login
    scope "/posts" do
      get "/", PostController, :index
      scope "/:tag_code" do
        get "/", PostController, :get_post_by_tag
      end
    end

    scope "/post" do
      get "/:post_id", PostController, :get_one_post 
    end

    scope "/user" do
      get "/", UserController, :index
      post "/sync_data", UserController, :login_and_sync_data
      post "/new_admin", UserController, :new_admin
    end
  end
  # Other scopes may use custom stacks.
  # scope "/api", SocialWeb do
  #   pipe_through :api
  # end
end
