require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/posts", type: :request do

  let(:current_user) { User.first_or_create(email: "user@example.com", password: "password") }
  let(:new_auth_header) { current_user.create_new_auth_token('client') }

  let(:valid_attributes) do {
    'title' => 'Test',
    'body' => 'Body',
    'user_id' => current_user.id,
  }
  end

  let(:invalid_attributes) do {
    'id' => 'a',
    'title' => 't',
    'body' => 'b',
    'user_id' => 'a',
  }
  end

  let(:valid_headers) do {
    "ACCEPT" => "application/json",
  } 
  end

  let(:authorization_valid_headers) { valid_headers.merge!(new_auth_header) }

  describe "GET /index" do
    it "renders a successful response" do
      get posts_url, headers: authorization_valid_headers
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      post = Post.create! valid_attributes
      get post_url(post), headers: authorization_valid_headers, as: :json
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Post" do
        expect {
          post posts_url,
               params: { post: valid_attributes }, headers: authorization_valid_headers
        }.to change(Post, :count).by(1)
      end

      it "renders a JSON response with the new post" do
        post posts_url,
             params: { post: valid_attributes }, headers: authorization_valid_headers
        expect(response).to be_successful
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Post" do
        expect {
          post posts_url,
               params: { post: invalid_attributes }, as: :json
        }.to change(Post, :count).by(0)
      end

      it "renders a JSON response with errors for the new post" do
        post posts_url,
             params: { post: invalid_attributes }, headers: authorization_valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
        'title' => 'New Title',
        'body' => 'New Body',
      }
    }

      it "updates the requested post" do
        post = Post.create! valid_attributes
        patch post_url(post),
              params: { post: new_attributes }, headers: authorization_valid_headers, as: :json
      end

      it "renders a JSON response with the post" do
        post = Post.create! valid_attributes
        patch post_url(post),
              params: { post: new_attributes }, headers: authorization_valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the post" do
        post = Post.create! valid_attributes
        patch post_url(post),
              params: { post: invalid_attributes }, headers: authorization_valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested post" do
      post = Post.create! valid_attributes
      expect {
        delete post_url(post), headers: authorization_valid_headers, as: :json
      }.to change(Post, :count).by(-1)
    end
  end
end
