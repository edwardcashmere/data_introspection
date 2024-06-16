defmodule DataIntrospectionWeb.Router do
  use DataIntrospectionWeb, :router

  import DataIntrospectionWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DataIntrospectionWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", DataIntrospectionWeb do
  #   pipe_through :browser

  #   get "/", PageController, :home
  # end

  # Other scopes may use custom stacks.
  # scope "/api", DataIntrospectionWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:data_introspection, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DataIntrospectionWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", DataIntrospectionWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {DataIntrospectionWeb.UserAuth, :redirect_if_user_is_authenticated},
        DataIntrospectionWeb.Hook.Nav
      ] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", DataIntrospectionWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {DataIntrospectionWeb.UserAuth, :ensure_authenticated},
        DataIntrospectionWeb.Hook.Nav
      ] do
      live "/", DashboardLive.Index, :index
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", DataIntrospectionWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [
        {DataIntrospectionWeb.UserAuth, :mount_current_user},
        DataIntrospectionWeb.Hook.Nav
      ] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/plots", DataIntrospectionWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :check_plots_ownership,
      on_mount: [
        {DataIntrospectionWeb.UserAuth, :ensure_authenticated},
        DataIntrospectionWeb.Hook.Nav
      ] do
      live "/private/:id", PlotsLive.Index, :self
      live "/shared/:id", PlotsLive.Index, :shared
      # live "/public/:id", PlotsLive.Index, :shared
    end
  end
end
