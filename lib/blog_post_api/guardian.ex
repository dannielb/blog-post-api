defmodule BlogPostApi.Guardian do
  use Guardian, otp_app: :blog_post_api
  alias BlogPostApi.Accounts

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    user = Accounts.get_user(id)
    {:ok, user}
  end
end
