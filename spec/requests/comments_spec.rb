# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/comments', type: :request do
  let(:user) { create(:user) }
  let(:my_post) { create(:post, user: user) }
  let(:comment) { create(:comment) }
  let(:my_comment) { create(:comment, user: user) }
  let(:auth_headers) { user.create_new_auth_token }

  let(:rand_int) { rand(1..20) }

  describe 'POST /comments' do
    context 'whith valid params' do
      it 'should create a comment in DB' do
        expect do
          post comments_url, params: { body: 'Bkah', post_id: my_post.id }, headers: auth_headers
        end.to change(Comment, :count).by(1)
      end

      it 'should create a current count of comments in DB' do
        expect do
          rand_int.times do
            post comments_url, params: { body: 'Bkah', post_id: my_post.id }, headers: auth_headers
          end
        end.to change(Comment, :count).by(rand_int)
      end

      it 'should create a comment for correct post' do
        expect do
          post comments_url, params: { body: 'yoy guys', post_id: my_post.id }, headers: auth_headers
        end.to change(Post.find(my_post.id).comments, :count).by(1)
      end

      it 'should create a current count of omments for correct post' do
        expect do
          rand_int.times do
            post comments_url, params: { body: 'yoy guys', post_id: my_post.id }, headers: auth_headers
          end
        end.to change(Post.find(my_post.id).comments, :count).by(rand_int)
      end

      it 'should create a comment belong to correct author' do
        post comments_url, params: { body: 'new body', post_id: my_post.id }, headers: auth_headers
        created_comment = Comment.find_by(body: 'new body')
        expect(created_comment.user_id).to eq(user.id)
      end

      it 'should send response with correct data' do
        post comments_url, params: { body: 'new body', post_id: my_post.id }, headers: auth_headers
        expect(response.body).to include('id', 'post_id', 'body', 'created_at', 'updated_at', 'author')
      end

      it 'should send response with correct status' do
        post comments_url, params: { body: 'new body', post_id: my_post.id }, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'whith invalid params' do
      it 'should not create a new comment' do
        expect do
          post comments_url, params: { body: 'n', post_id: my_post.id }, headers: auth_headers
        end.to_not change(Comment, :count)
      end

      it 'should send response with any error messages' do
        post comments_url, params: { body: '', post_id: '' }, headers: auth_headers
        expect(response.body).to_not be_empty
      end

      it 'should send a correct response status ' do
        post comments_url, params: { body: 'correct body', post_id: '' }, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'whithout authentication token' do
      it 'should not create post' do
        expect do
          rand_int.times do
            post comments_url, params: { body: 'correct body', post_id: my_post.id }
          end
        end.to_not change(Comment, :count)
      end

      it 'should send response with unauthorized error message' do
        post comments_url, params: { body: 'correct body', post_id: my_post.id }
        expect(response.body).to include('You need to sign in or sign up before continuing')
      end

      it 'should send a correct response status' do
        post comments_url, params: { body: 'correct body', post_id: my_post.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /comments/:id' do
    context 'with valid params' do
      it 'should updated existed comment' do
        put comment_url(my_comment), params: { body: 'updated body' }, headers: auth_headers
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq('updated body')
      end

      it 'should send response with correct updated comment' do
        put comment_url(my_comment), params: { body: my_comment.body = 'updated body' }, headers: auth_headers
        comment_from_response = JSON.parse(response.body)
        expect(comment_from_response['id']).to eq(my_comment.id)
        expect(comment_from_response['post_id']).to eq(my_comment.post_id)
        expect(comment_from_response['body']).to eq(my_comment.body)
      end

      it 'should response with correct status' do
        put comment_url(my_comment), params: { body: my_comment.body = 'updated body' }, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it "shouldn't let you update comment that doesn't belong to you" do
        put comment_url(comment), params: { body: 'updated body' }, headers: auth_headers
        comment_from_db = Comment.find(comment.id)
        expect(comment_from_db.body).to eq(comment.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to_not be_empty
      end
    end

    context 'with invalid params' do
      it "shouldn't let you update comment" do
        put comment_url(my_comment), params: { body: '' }, headers: auth_headers
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq(my_comment.body)
      end

      it 'should send response with any errors' do
        put comment_url(my_comment), params: { body: '' }, headers: auth_headers
        expect(response.body).to_not be_empty
      end

      it 'should send response with correct status' do
        put comment_url(my_comment), params: { body: '' }, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      context "with comment that doesn't exist" do
        it 'should send response with correct error message' do
          put comment_url(-1), params: { body: 'updated body' }, headers: auth_headers
          expect(response.body).to include("Couldn't find")
        end

        it 'should send response with correct status' do
          put comment_url(-1), params: { body: 'updated body' }, headers: auth_headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'whithout authentication token' do
      it "shouldn't change comment" do
        put comment_url(my_comment), params: { body: 'changed body' }
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq(my_comment.body)
      end

      it 'should send response with unauthorized error message' do
        put comment_url(my_comment), params: { body: 'changed body' }
        expect(response.body).to include('You need to sign in or sign up before continuing')
      end

      it 'should send a correct response status' do
        put comment_url(my_comment), params: { body: 'changed body' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /comments/:id' do
    context 'with valid params' do
      it 'should delete corrent comment' do
        expect do
          delete comment_url(my_comment), headers: auth_headers
        end.to change(Comment, :count).by(0)
      end

      it 'should send a correct response status' do
        delete comment_url(my_comment), headers: auth_headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with invalid params' do
      context "with comment that dosn't belong to you" do
        it "shouldn't let you delete comment" do
          comment
          expect do
            delete comment_url(comment), headers: auth_headers
          end.to_not change(Comment, :count)
        end

        it 'should send you response with correct error message' do
          delete comment_url(comment), headers: auth_headers
          expect(response.body).to include("dosn't belong to you")
        end

        it 'should send you response with correct response status' do
          delete comment_url(comment), headers: auth_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
