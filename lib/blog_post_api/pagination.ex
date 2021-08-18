defmodule BlogPostApi.Pagination do
  @moduledoc """
  Module that includes `page/3` for pagination query.
  """
  import Ecto.Query
  alias BlogPostApi.Repo

  @default_per_page 15

  def page(query, page, opts  \\ [])

  def page(query, page, opts) when is_nil(page),
    do: page(query, 1, opts)

  def page(query, page, opts) when page <= 0, do: page(query, 1, opts)

  def page(query, page, opts) when is_binary(page),
    do: page(query, String.to_integer(page), opts)

  def page(query, page, opts) do
    per_page = Keyword.get(opts, :per_page, @default_per_page)
    page = page - 1
    count = per_page + 1

    entries =
      query
      |> limit(^count)
      |> offset(^(page * per_page))
      |> Repo.all()

    has_next = length(entries) == count
    has_prev = page > 1
    total_count = Repo.one(from(t in subquery(query), select: count("*")))

    %{
      has_next: has_next,
      has_prev: has_prev,
      prev_page: page,
      next_page: page + 2,
      current_page: page + 1,
      count: total_count,
      entries: entries
    }
  end
end
