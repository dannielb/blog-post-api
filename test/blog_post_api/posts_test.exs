defmodule BlogPostApi.PostsTest do
  use BlogPostApi.DataCase

  alias BlogPostApi.Posts
  alias BlogPostApi.Posts.Post

  describe "create_post/1" do
    setup do
      user = Factory.insert(:user)
      %{user: user}
    end

    test "success: it inserts a post in the db and returns the post", %{user: user} do
      params =
        Factory.string_params_for(:post)
        |> Map.merge(%{"user_id" => user.id})

      assert {:ok, %Post{} = returned_post} = Posts.create_post(params)
      post_from_db = Repo.get(Post, returned_post.id)

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(post_from_db, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{
                 inspect(actual)
               }"
      end

      assert post_from_db.published == post_from_db.updated
    end

    test "error: returns an error tuple when post can't be created" do
      bad_params = %{}
      assert {:error, %Changeset{valid?: false}} = Posts.create_post(bad_params)
    end
  end

  describe "get_post/1" do
    test "success: it returns a post when given a valid UUID" do
      existing_post = Factory.insert(:post)
      assert {:ok, returned_post} = Posts.get_post(existing_post.id)
      assert %BlogPostApi.Accounts.User{} = returned_post.user
    end

    test "error: it returns an error tuple when a post doesn't exist" do
      assert {:error, :not_found} = Posts.get_post(Faker.UUID.v4())
    end
  end

  describe "update_post/2" do
    setup [:create_post]

    test "success: it updates database and returns the updated post", %{post: post} do
      params =
        Factory.string_params_for(:post)
        |> Map.take(["title"])

      assert {:ok, returned_post} = Posts.update_post(post, params)

      post_from_db = Repo.get(Post, returned_post.id)

      expected_post_data =
        post
        |> Map.from_struct()
        |> Map.drop([:__meta__, :published, :updated, :user])
        |> Map.put(:title, params["title"])

      for {field, expected} <- expected_post_data do
        actual = Map.get(post_from_db, field)

        assert actual == expected, "Values mismatch on update, field: #{field} \n
          expected: #{expected} \n
          actual: #{actual}"
      end
    end

    test "error: returns an error tuple when post can't be updated", %{post: post} do
      bad_params = %{"title" => nil}
      assert {:error, %Changeset{}} = Posts.update_post(post, bad_params)
    end
  end

  describe "delete/1" do
    test "success: it deletes the post" do
      post = Factory.insert(:post)
      assert {:ok, _} = Posts.delete_post(post)

      refute Repo.get(Post, post.id)
    end
  end

  describe "search/1" do
    @max_posts 50
    setup [:create_many_posts]

    test "success: returns posts based on title", %{posts: posts} do
      searched_post = Enum.random(posts)

      search_term =
        String.split(searched_post.title)
        |> Enum.random()

      Posts.search_post(search_term)
      |> assert_search_results(search_term)
    end

    test "success: returns posts based on content", %{posts: posts} do
      searched_post = Enum.random(posts)

      search_term =
        String.split(searched_post.content)
        |> Enum.random()

      Posts.search_post(search_term)
      |> assert_search_results(search_term)
    end

    test "success: returns all posts if no query give" do
      assert Enum.count(Posts.search_post("")) == @max_posts
    end

    test "error: returns nothing with 'invalid query'" do
      assert Posts.search_post("invalid_term") == []
    end
  end

  describe "paginate_posts/1" do
    @default_per_page 15
    setup [:create_many_posts]

    test "success: returns posts in a valid number per page" do
      result = Posts.paginate_posts(1)

      assert %{
        has_next: true,
        has_prev: false,
        count: 50,
        next_page: 2,
        prev_page: 0,
        entries: _
      } = result

      assert Enum.count(result[:entries]) == @default_per_page + 1
      assert %Post{} = List.first(result[:entries])
      assert %{has_next: false, entries: []} = Posts.paginate_posts(5)
    end
  end

  defp create_post(_) do
    post = Factory.insert(:post)
    %{post: post}
  end

  defp create_many_posts(_) do
    posts = Factory.insert_list(50, :post)
    %{posts: posts}
  end

  defp assert_search_results(results, search_term) do
    search_term = String.downcase(search_term)

    for result <- results do
      title = String.downcase(result.title)
      content = String.downcase(result.content)

      assert String.contains?(title, search_term) or String.contains?(content, search_term),
             "term \"#{search_term}\" not found in title \"#{title}\" or content in title \"#{
               content
             }\ "
    end
  end
end
