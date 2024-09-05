defmodule DocumentParserWeb.Router do
  use DocumentParserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DocumentParserWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DocumentParserWeb do
    pipe_through :api

    resources "/legal_documents", LegalDocumentController, except: [:new, :edit]
  end

  scope "/", DocumentParserWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/legal_documents", LegalDocumentLive.Index, :index
    live "/legal_documents/new", LegalDocumentLive.Index, :new
    live "/legal_documents/:id/edit", LegalDocumentLive.Index, :edit

    live "/legal_documents/:id", LegalDocumentLive.Show, :show
    live "/legal_documents/:id/show/edit", LegalDocumentLive.Show, :edit

    live "/filter_phrases", FilterPhraseLive.Index, :index
    live "/filter_phrases/new", FilterPhraseLive.Index, :new
    live "/filter_phrases/:id/edit", FilterPhraseLive.Index, :edit

    live "/filter_phrases/:id", FilterPhraseLive.Show, :show
    live "/filter_phrases/:id/show/edit", FilterPhraseLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", DocumentParserWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:document_parser, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DocumentParserWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
