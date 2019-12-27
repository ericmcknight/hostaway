defmodule JSONAPI.Settings do
    def get_url() do
        Confex.fetch_env!(:hostaway, :hostaway_url)
    end
end