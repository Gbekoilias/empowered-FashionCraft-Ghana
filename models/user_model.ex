defmodule MyApp.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyApp.Repo

  # Define the user schema
  schema "users" do
    field :username, :string
    field :password_hash, :string

    timestamps()
  end

  # Changeset function to handle user data validation and hashing
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 3)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:username)
    |> put_pass_hash()
  end

  # Function to hash the password before saving to the database
  defp put_pass_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset # No password provided, return unchanged changeset
      password ->
        hash = Bcrypt.hash_pwd_salt(password) # Hash the password using Bcrypt
        put_change(changeset, :password_hash, hash)
    end
  end

  # Function to register a new user
  def register_user(attrs) do
    %MyApp.User{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  # Function to authenticate a user by username and password
  def authenticate_user(username, password) do
    user = Repo.get_by(MyApp.User, username: username)

    case user do
      nil -> {:error, "User not found"}
      _ ->
        if Bcrypt.check_pass(user, password) do
          {:ok, user}
        else
          {:error, "Invalid password"}
        end
    end
  end

end
