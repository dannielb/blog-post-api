defmodule BlogPostApi.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias BlogPostApi.Repo

  alias BlogPostApi.Accounts.User
  alias BlogPostApi.Posts.Post
  alias BlogPostApi.Pagination

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
    |> Repo.preload(:user)
  end

  @doc """
  Returns a list of posts paginated.

  iex> paginate_posts()
   %{
      has_next: true,
      has_prev: false,
      prev_page: 0,
      next_page: 1,
      current_page: 1,
      count: total_count,
      entries:  [%Post{}, ...]
    }
  """
  def paginate_posts(page \\ 1) do
    result =
      Post
      |> Pagination.page(page)

    Map.put(result, :entries, Repo.preload(result[:entries], :user))
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post(123)
      %Post{}

      iex> get_post(456)
      {:error, :not_found}

  """
  def get_post(id) do
    if post = Repo.get(Post, id) do
      post = Repo.preload(post, :user)
      {:ok, post}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    Post.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def is_the_owner?(%Post{} = post, %User{} = user) do
    if post.user_id == user.id do
      {:ok, post}
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Searchs a post by title or content.

  ## Examples
      iex> search_post(term)
      [%Post{}, ...]
  """
  def search_post(""), do: list_posts()

  def search_post(term) do
    term = "%" <> String.replace(term, " ", "%") <> "%"

    from(p in Post,
      where: ilike(p.title, ^term),
      or_where: ilike(p.content, ^term)
    )
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
