defmodule JSONAPI.Schemas.Booking do
    use Ecto.Schema
    import Ecto.Changeset

    schema "booking" do
        field :listing_id, :integer
        field :arrival_date, :date
        field :departure_date, :date
        field :first_name, :string
        field :last_name, :string
        field :adults, :integer
        field :children, :integer
        field :email, :string
        field :phone, :string
        field :total, :float
        field :taxes, :float
        field :cleaning_fee, :float
        field :is_paid, :boolean
    end

    @allowed_fields [:listing_id, :arrival_date, :departure_date, :first_name, :last_name, :adults, :children, 
                     :email, :phone, :total, :taxes, :cleaning_fee, :is_paid]

    def changeset(booking, params \\ %{}) do
        booking
        |> cast(params, @allowed_fields)
        |> validate_format(:email, ~r/@/)
    end
end