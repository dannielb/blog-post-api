defmodule BlogPostApiWeb.ChangesetView do
  use BlogPostApiWeb, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `BlogPostApiWeb.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{error: error}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{message: translate_error(error)}
  end
end
