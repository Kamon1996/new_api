# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:new_post) { create(:post, user: user) }
  let(:my_comment) { create(:comment, user: user) }
  let(:auth_headers) { user.create_new_auth_token }

  describe 'comments#create' do
    context 'when usesd valid params' do
      it 'should create a comment for correct post' do
        post :create, params: auth_headers.merge(body: 'yoy guys', post_id: new_post.id)
        expect(json['post_id']).to eq(new_post.id)
      end

      it 'should create a comment that belongs to correct author' do
        post :create, params: auth_headers.merge(body: 'new body', post_id: new_post.id)
        expect(json['author']['id']).to eq(user.id)
      end

      it 'should send response with correct data and status' do
        post :create, params: auth_headers.merge(body: 'new body', post_id: new_post.id)
        expect(response.body).to include('id', 'post_id', 'body', 'created_at', 'updated_at', 'author')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when usesd invalid params' do
      it "shouldn't create a new comment and send response with correct error message and status" do
        expect do
          post :create, params: auth_headers.merge(body: '', post_id: '')
        end.to_not change(Comment, :count)
        expect(response.body).to include('Post must exist', "Body can't be blank", 'Body is too short')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user not authorized' do
      it "shouldn't create post and send response with correct error message and status" do
        expect do
          post :create, params: { body: 'correct body', post_id: new_post.id }
        end.to_not change(Comment, :count)
        expect(response.body).to include('You need to sign in or sign up before continuing')
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'comments#update' do
    context 'when used valid params' do
      it 'should updated existed comment and send correct status with response' do
        put :update, params: auth_headers.merge(body: 'updated body', id: my_comment)
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq('updated body')
        expect(response).to have_http_status(:ok)
      end

      it 'should send response with correct updated comment' do
        put :update, params: auth_headers.merge(body: 'updated body', id: my_comment)
        expect(json['id']).to eq(my_comment.id)
        expect(json['post_id']).to eq(my_comment.post_id)
        expect(json['body']).to eq('updated body')
      end

      it "shouldn't let you update comment that doesn't belongs to you and send coorect error message and status with response" do
        comment = create(:comment)
        put :update, params: auth_headers.merge(body: 'updated body', id: comment)
        comment_from_db = Comment.find(comment.id)
        expect(comment_from_db.body).to eq(comment.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("doesn't belong to you.")
      end
    end

    context 'when used invalid params' do
      it "shouldn't let you update comment and send response with correct error messages and status" do
        put :update, params: auth_headers.merge(body: '', id: my_comment)
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq(my_comment.body)
        expect(response.body).to include("Body can't be blank", 'Body is too short')
        expect(response).to have_http_status(:unprocessable_entity)
      end

      context "when used comment that doesn't exist" do
        it 'should send response with correct error message and status' do
          put :update, params: auth_headers.merge(body: 'updated body', id: -1)
          expect(response.body).to include("Couldn't find")
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user not authorized' do
      it "shouldn't change comment and send correct error message and status with response" do
        put :update, params: { body: 'changed body', id: my_comment }
        comment_from_db = Comment.find(my_comment.id)
        expect(comment_from_db.body).to eq(my_comment.body)
        expect(response.body).to include('You need to sign in or sign up before continuing')
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'comments#destroy' do
    context 'when used valid params' do
      it 'should delete corrent comment and send correct response status' do
        expect do
          delete :destroy, params: auth_headers.merge(id: my_comment)
        end.to change(Comment, :count).by(0)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when used invalid params' do
      context "when used comment that doesn't belong to you." do
        it "shouldn't let you delete comment and send response with correct error message and status" do
          comment = create(:comment)
          expect do
            delete :destroy, params: auth_headers.merge(id: comment)
          end.to_not change(Comment, :count)
          expect(response.body).to include("doesn't belong to you.")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
