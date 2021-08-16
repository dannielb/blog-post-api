defmodule BlogPostApiWeb.AuthView do
  use BlogPostApiWeb, :view

  def render("unauthorized.json", _) do
    %{"message" => "Token não encontrado"}
  end
end
