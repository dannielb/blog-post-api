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

## Current features:

- [x] route for register a user and return a valid jwt token

- [x] route for login a user and return a valid jwt token

- [x] route for see a single or multiple users

- [x] route for deleting the current user

- [x] route for create and update a blog post

- [x] route for see a single or multile posts

- [x] route for searching a post by it title or content

- [x] route for deleting a post

