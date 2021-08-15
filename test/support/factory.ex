defmodule BlogPostApi.Factory do
  use ExMachina.Ecto, repo: BlogPostApi.Repo
  alias BlogPostApi.Accounts.User

  def user_factory do
    %User{
      display_name: Faker.Person.name(),
      email: Faker.Internet.email(),
      password: Faker.String.base64()
    }
  end

  def invalid_user_factory do
    %User{
      display_name: DateTime.utc_now(),
      email: DateTime.utc_now(),
      password: Enum.random(1..10)
    }
  end
end
