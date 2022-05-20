require 'rails_helper'

RSpec.describe "/comments", type: :request do
  let(:user) { create(:user) }
  let(:user_post) { create(:post, user: user) }
  let(:comment) { create(:comment, post: post) }
  let(:auth_headers) { user.create_new_auth_token.merge('ACCEPT' => 'application/json') }

  let(:rand_int) { rand(1..20) }

  describe "POST /comments" do
    context "whith valid params" do
      it "should create a comment in DB" do
        expect {
            post comments_url, params: { body: 'Bkah', post_id: user_post.id }, headers: auth_headers
      }.to change(Comment, :count).by(1)
      end

      it "should create a current count of comments in DB" do
        expect {
          rand_int.times do
            post comments_url, params: { body: 'Bkah', post_id: user_post.id }, headers: auth_headers
          end
      }.to change(Comment, :count).by(rand_int)
      end

      it "should create a comment for correct post" do
        expect {
          post comments_url, params: { body: "yoy guys", post_id: user_post.id }, headers: auth_headers
      }.to change(Post.find(user_post.id).comments, :count).by(1)
      end

      it "should create a current count of omments for correct post" do
        expect {
          rand_int.times do
            post comments_url, params: { body: "yoy guys", post_id: user_post.id }, headers: auth_headers
          end
      }.to change(Post.find(user_post.id).comments, :count).by(rand_int)
      end

      it "should create a comment belong to correct author" do
        post comments_url, params: { body: "new body", post_id: user_post.id }, headers: auth_headers
        created_comment = Comment.find_by(body: "new body")
        expect(created_comment.user_id).to eq(user.id)
      end

      it "should send response with correct data" do
        post comments_url, params: { body: "new body", post_id: user_post.id }, headers: auth_headers
        expect(response.body).to include("id", "post_id", "body", "created_at", "updated_at", "author")
      end

      it "should send response with correct status" do
        post comments_url, params: { body: "new body", post_id: user_post.id }, headers: auth_headers
        expect(response).to have_http_status(:created)
      end
    end

    context "whith invalid params" do
    end

    context "whithout authentication token" do
    end
  end

  describe "PATCH /comments/:id" do
  end

  describe "DELETE /comments/:id" do
  end

end