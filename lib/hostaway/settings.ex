defmodule JSONAPI.Settings do
    def get_url() do
        Confex.fetch_env!(:hostaway, :hostaway_url)
    end

    def get_stripe_publishable_key() do
        Confex.fetch_env!(:hostaway, :stripe_publishable_key)
    end

    def get_stripe_secret_key() do
        Confex.fetch_env!(:hostaway, :stripe_secret_key)
    end
end