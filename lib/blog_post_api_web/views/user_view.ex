defmodule BlogPostApiWeb.UserView do
  use BlogPostApiWeb, :view
  alias BlogPostApiWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("token.json", %{token: token}) do
    %{token: token}
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      display_name: user.display_name,
      email: user.email,
      image: user.image
    }
  end

  def render("index_paginated.json", %{pagination: pagination}) do
    %{
      has_next: pagination.has_next,
      has_prev: pagination.has_prev,
      prev_page: pagination.prev_page,
      next_page: pagination.next_page,
      current_page: pagination.current_page,
      count: pagination.count,
      entries: render_many(pagination.entries, UserView, "user.json")
    }
  end

  def render("404.json", _params) do
    %{message: "Usuário não existe"}
  end
end
