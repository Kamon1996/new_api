require 'rails_helper'

RSpec.describe "/posts", type: :request do

  let(:current_user) { create(:user) }
  let(:created_post) { create(:post, user: current_user)}
  let(:auth_valid_headers) { current_user.create_new_auth_token('client').merge("ACCEPT" => "application/json") }
  let(:invalid_headers) { {"ACCEPT" => "application/json"} }
  let(:new_post) { build(:post) }
  let(:new_post_invalid) { build(:post, title: "1", body: "1") }

  describe "GET /index" do
    context "with valid headers" do
      it "renders a correct status" do
        get posts_url, headers: auth_valid_headers
        expect(response).to have_http_status(200)
      end

      it "renders correct count of Posts" do
        make_few_posts(user: current_user)
        get posts_url, headers: auth_valid_headers
        response_posts_length = JSON.parse(response.body)['posts'].length
        expect(response_posts_length).to eq(Post.all.count)
      end
    end

    context "with no-auth headers" do
      it "renders a correct error" do
        get posts_url, headers: invalid_headers
        response_error_message = JSON.parse(response.body)['errors'][0]
        expect(response).to have_http_status(401)
        expect(response_error_message).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "GET /show" do
    context "with valid headers" do

      context "with existed post" do
        it "renders a correct status" do
          get post_url(created_post), headers: auth_valid_headers
          expect(response).to have_http_status(200)
        end

        it "renders a correct post" do
          get post_url(created_post), headers: auth_valid_headers
          response_post_id = JSON.parse(response.body)["id"]
          expect(response_post_id).to eq(created_post.id)
        end
      end

      context "with non-existed post" do
        it "renders a correct status" do
          make_few_posts(user: current_user)
          get post_url(-1), headers: auth_valid_headers
          expect(response).to have_http_status(404)
        end

        it "renders a correct error" do
          get post_url(-1), headers: auth_valid_headers
          response_error_message = JSON.parse(response.body)['error']
          expect(response_error_message).to include("Post does not exist")
        end
      end
    end

    context "with invalid headers" do
      it "renders a correct error" do
        get post_url(created_post), headers: invalid_headers
        response_error_message = JSON.parse(response.body)['errors'][0]
        expect(response).to have_http_status(401)
        expect(response_error_message).to include("You need to sign in or sign up before continuing.")
      end
    end

  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Post in DB" do
        expect {
          post posts_url, params: { post: new_post.as_json }, headers: auth_valid_headers
        }.to change(Post, :count).by(1)
      end

      it "renders a correct status" do
        post posts_url, params: { post: new_post.as_json }, headers: auth_valid_headers
        expect(response).to have_http_status(201)
      end

      it "renders back created Post" do
        post posts_url, params: { post: new_post.as_json }, headers: auth_valid_headers
        post_from_response = JSON.parse(response.body)
        expect(post_from_response["title"]).to eq(new_post["title"])
        expect(post_from_response["body"]).to eq(new_post["body"])
      end
    end

    context "with invalid parameters" do
      it "does not create a new Post" do
        expect {
          post posts_url,
               params: { post: new_post_invalid.as_json }, headers: auth_valid_headers
        }.to change(Post, :count).by(0)
      end

      it "renders a correct status" do
        post posts_url,
             params: { post: new_post_invalid.as_json }, headers: auth_valid_headers
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested post" do
        expect {
          patch post_url(created_post),
          params: { post: new_post.as_json }, headers: auth_valid_headers
          }.to change(Post, :count).by(1)
        post_from_response = JSON.parse(response.body)
        expect(post_from_response["title"]).to eq(new_post["title"])
        expect(post_from_response["body"]).to eq(new_post["body"])
        expect(post_from_response["id"]).to eq(created_post["id"])
        expect(post_from_response["updated_at"]).to_not eq(created_post["updated_at"])
      end

      it "renders a correct status" do
        patch post_url(created_post),
              params: { post: new_post.as_json }, headers: auth_valid_headers
        expect(response).to have_http_status(200)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the post" do
        patch post_url(created_post),
              params: { post: new_post_invalid.as_json }, headers: auth_valid_headers
        expect(response).to have_http_status(422)
        errors_from_response = JSON.parse(response.body)
        expect(errors_from_response).not_to be_empty
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested post" do
      expect {
        delete post_url(created_post), headers: auth_valid_headers
      }.to change(Post, :count).by(0)
    end

    it "won't let you delete a post that isn't yours" do
      make_few_posts(user: create(:user))
      expect {
        delete post_url(Post.first), headers: auth_valid_headers
    }.to change(Post, :count).by(0)
    expect(response.body).to eq("You cant destroy a post that doesnt belong to you")
    end
  end
end
