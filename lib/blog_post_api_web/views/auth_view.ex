defmodule BlogPostApiWeb.AuthView do
  use BlogPostApiWeb, :view

  def render("unauthorized.json", _) do
    %{"message" => "Token não encontrado"}
  end

  def render("invalid_token.json", _) do
    %{"message" => "Token expirado ou Invalido"}
  end

  def render("user_without_privileges.json", _) do
    %{"message" => "Usuário nao authorizado"}
  end
end
