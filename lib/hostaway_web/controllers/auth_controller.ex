defmodule HostawayWeb.AuthController do
    use HostawayWeb, :controller

    def index(conn, _params) do
        {_, value} = JSONAPI.Authentication.auth()
        render(conn, "index.json", result: value)
    end
end