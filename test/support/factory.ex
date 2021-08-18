defmodule BlogPostApi.Factory do
  use ExMachina.Ecto, repo: BlogPostApi.Repo
  alias BlogPostApi.Accounts.User
  alias BlogPostApi.Posts.Post

  def user_factory do
    %User{
      display_name: Faker.Person.name(),
      email: Faker.Internet.email(),
      password: Faker.String.base64(),
      image: Faker.Internet.image_url()
    }
  end

  def invalid_user_factory do
    %User{
      display_name: DateTime.utc_now(),
      email: DateTime.utc_now(),
      password: Enum.random(1..10),
      image: DateTime.utc_now()
    }
  end

  def post_factory do
    %Post{
      title: Faker.Lorem.sentence(),
      content: Faker.Lorem.paragraph(),
      user: build(:user)
    }
  end

  def invalid_post_factory do
    %Post{
      title: DateTime.utc_now(),
      content: Enum.random(1..5),
      user_id: DateTime.utc_now()
    }
  end
end
