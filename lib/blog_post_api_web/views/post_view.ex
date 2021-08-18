defmodule BlogPostApiWeb.PostView do
  use BlogPostApiWeb, :view
  alias BlogPostApiWeb.PostView
  alias BlogPostApiWeb.UserView

  def render("index.json", %{posts: posts}) do
    render_many(posts, PostView, "post.json")
  end

  def render("show.json", %{post: post}) do
    render_one(post, PostView, "post.json")
  end

  def render("post.json", %{post: %{user: user} = post}) do
    %{
      id: post.id,
      title: post.title,
      content: post.content,
      published: to_string(post.published),
      updated: to_string(post.updated),
      user: render_one(user, UserView, "show.json")
    }
  end

  def render("simple_post.json", %{post: post}) do
    %{id: post.id, title: post.title, content: post.content, user_id: post.user_id}
  end

  def render("404.json", _params) do
    %{message: "Post não existe"}
  end
end
