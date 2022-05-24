# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:new_post) { create(:post, user: user) }
  let(:comment) { create(:comment) }
  let(:my_comment) { create(:comment, user: user) }
  let(:auth_headers) { user.create_new_auth_token }

  describe 'comments#create' do
    context 'whith valid params' do
      it 'should create a comment for correct post' do
        expect do
          post :create, params: auth_headers.merge(body: 'yoy guys', post_id: new_post.id)
        end.to change(Post.find(new_post.id).comments, :count).by(1)
      end

      it 'should create a comment that belongs to correct author' do
        post :create, params: auth_headers.merge(body: 'new body', post_id: new_post.id)
        created_comment = Comment.find_by(body: 'new body')
        expect(created_comment.user_id).to eq(user.id)
      end

      it 'should send response with correct data' do
        post :create, params: auth_headers.merge(body: 'new body', post_id: new_post.id)
        expect(response.body).to include('id', 'post_id', 'body', 'created_at', 'updated_at', 'author')
      end

      it 'should send response with correct status' do
        post :create, params: auth_headers.merge(body: 'new body', post_id: new_post.id)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'whith invalid params' do
      it 'should not create a new comment' do
        expect do
          post :create, params: auth_headers.merge(body: 'n', post_id: new_post.id)
        end.to_not change(Comment, :count)
      end

      it 'should send response with any error messages' do
        post :create, params: auth_headers.merge(body: '', post_id: '')
        expect(response.body).to_not be_empty
      end

      it 'should send a correct response status ' do
        post :create, params: auth_headers.merge(body: 'correct body', post_id: '')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'whithout authentication token' do
      it 'should not create post' do
        expect do
          post :create, params: { body: 'correct body', post_id: new_post.id }
        end.to_not change(Comment, :count)
      end

      it 'should send response with unauthorized error message' do
        post :create, params: { body: 'correct body', post_id: new_post.id }
        expect(response.body).to include('You need to sign in or sign up before continuing')
      end

      it 'should send a correct response status' do
        post :create, params: { body: 'correct body', post_id: new_post.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'comments#update' do
    context 'with valid params' do
      it 'should updated existed comment' do
        put :update, params: auth_headers.merge(body: 'updated body', id: my_comment)
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq('updated body')
      end

      it 'should send response with correct updated comment' do
        put :update, params: auth_headers.merge(body: 'updated body', id: my_comment)
        expect(json['id']).to eq(my_comment.id)
        expect(json['post_id']).to eq(my_comment.post_id)
        expect(json['body']).to eq('updated body')
      end

      it 'should response with correct status' do
        put :update, params: auth_headers.merge(body: 'updated body', id: my_comment)
        expect(response).to have_http_status(:ok)
      end

      it "shouldn't let you update comment that doesn't belong to you" do
        put :update, params: auth_headers.merge(body: 'updated body', id: comment)
        comment_from_db = Comment.find(comment.id)
        expect(comment_from_db.body).to eq(comment.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to_not be_empty
      end
    end

    context 'with invalid params' do
      it "shouldn't let you update comment" do
        put :update, params: auth_headers.merge(body: '', id: my_comment)
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq(my_comment.body)
      end

      it 'should send response with any errors' do
        put :update, params: auth_headers.merge(body: '', id: my_comment)
        expect(response.body).to_not be_empty
      end

      it 'should send response with correct status' do
        put :update, params: auth_headers.merge(body: '', id: my_comment)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      context "with comment that doesn't exist" do
        it 'should send response with correct error message' do
          put :update, params: auth_headers.merge(body: 'updated body', id: -1)
          expect(response.body).to include("Couldn't find")
        end

        it 'should send response with correct status' do
          put :update, params: auth_headers.merge(body: 'updated body', id: -1)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'whithout authentication token' do
      it "shouldn't change comment" do
        put :update, params: { body: 'changed body', id: my_comment }
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq(my_comment.body)
      end

      it 'should send response with unauthorized error message' do
        put :update, params: { body: 'changed body', id: my_comment }
        expect(response.body).to include('You need to sign in or sign up before continuing')
      end

      it 'should send a correct response status' do
        put :update, params: { body: 'changed body', id: my_comment }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'comments#destroy' do
    context 'with valid params' do
      it 'should delete corrent comment' do
        expect do
          delete :destroy, params: auth_headers.merge(id: my_comment)
        end.to change(Comment, :count).by(0)
      end

      it 'should send a correct response status' do
        delete :destroy, params: auth_headers.merge(id: my_comment)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with invalid params' do
      context "with comment that dosn't belong to you" do
        it "shouldn't let you delete comment" do
          comment
          expect do
            delete :destroy, params: auth_headers.merge(id: comment)
          end.to_not change(Comment, :count)
        end

        it 'should send you response with correct error message' do
          delete :destroy, params: auth_headers.merge(id: comment)
          expect(response.body).to include("dosn't belong to you")
        end

        it 'should send you response with correct response status' do
          delete :destroy, params: auth_headers.merge(id: comment)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
