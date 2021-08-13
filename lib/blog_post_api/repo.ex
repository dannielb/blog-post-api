defmodule BlogPostApi.Repo do
  use Ecto.Repo,
    otp_app: :blog_post_api,
    adapter: Ecto.Adapters.Postgres
end
