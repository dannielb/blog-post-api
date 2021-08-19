# Blog API
A simple application for creation of blog posts.

How to run the project:
  - Clone this repo.
  - certifies that elixir/erlang is configured(minimum: Elixir 1.11.1 - Erlang/OTP 23).
  - if necessary, change the default database authentication config on `config/dev.exs` and `config/test.exs`
  - run `mix setup`
  - run `mix phx.server`
  - if everything goes ok, the application will be available by default on port 4000.

How to run the tests:
  - run  `mix test`

Application deployed on heroku and can also be used by its endpoint: `https://blog--post-api.herokuapp.com`.

All routes can be manually tested with `insomnia` using the exported collection(`insomnia_collection`).

## Current features:

- [x] route for register a user and return a valid jwt token

- [x] route for login a user and return a valid jwt token

- [x] route for see a single or multiple users

- [x] route for deleting the current user

- [x] route for create and update a blog post

- [x] route for see a single or multile posts

- [x] route for searching a post by it title or content

- [x] route for deleting a post

- [x] route for getting all users or posts with validation(most safe than receive All data in a table with just one request)

## improvement points.

- currently the Posts's search is a simple `ilike` query, despite being functional, it is necessary to score exactly the text to be searched to receive good results, an option for the next viable level would be to use something like [Postgres's Full text search](https://www.postgresql.org/docs/9.5/textsearch.html).

## Dependencies

[Phoenix](https://phoenixframework.org/)

[Guardian](https://hexdocs.pm/guardian/Guardian.html)

[Bcrypt](https://hexdocs.pm/bcrypt_elixir/Bcrypt.html)

[Faker](https://hexdocs.pm/faker/api-reference.html)

[ExMachina](https://hexdocs.pm/ex_machina/readme.html)

[Credo](https://hexdocs.pm/credo/overview.html)

