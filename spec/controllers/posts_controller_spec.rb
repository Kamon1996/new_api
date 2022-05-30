# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:current_user) { create(:user) }
  let(:created_post) { create(:post, user: current_user) }
  let(:auth_headers) { current_user.create_new_auth_token }

  describe 'posts#index' do
    context 'when used valid headers' do
      it 'should send correct count of posts and correct status with response' do
        create_list(:post, 3)
        get :index, params: auth_headers
        expect(json['posts'].count).to eq(Post.all.count)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'posts#show' do
    context 'when used valid params' do
      it 'should send response when used correct post and status' do
        get :show, params: auth_headers.merge(id: created_post)
        expect(json['id']).to eq(created_post.id)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when used non-existed post' do
      it 'should send a correct error message and status with response' do
        get :show, params: auth_headers.merge(id: -1)
        expect(response.body).to include("Couldn't find")
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'posts#create' do
    context 'when used valid params' do
      it 'should create a new post in database and send correct post and status with response' do
        expect do
          post :create, params: auth_headers.merge(post: { title: 'new title', body: 'new body' })
        end.to change(Post, :count).by(1)
        expect(json['title']).to eq('new title')
        expect(json['body']).to eq('new body')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when used invalid parameters' do
      it "should doesn't create a new post" do
        expect do
          post :create, params: auth_headers.merge(post: { title: '1', body: '1' })
        end.to change(Post, :count).by(0)
      end

      it 'should send a correct error messages and status with response' do
        post :create, params: auth_headers.merge(post: { title: '', body: '' })
        expect(response.body).to include('Title is too short', 'Body is too short')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'posts#update' do
    context 'when used valid parameters' do
      it 'should update the correct post and send changed post and status with response' do
        put :update, params: auth_headers.merge(id: created_post, post: { title: 'updated', body: 'updated' })
        expect(json['title']).to eq('updated')
        expect(json['body']).to eq('updated')
        expect(json['id']).to eq(created_post['id'])
        expect(json['updated_at']).to_not eq(created_post['updated_at'])
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when used invalid parameters' do
      it 'should send correct error messages and status with response' do
        put :update, params: auth_headers.merge(id: created_post, post: { title: '1' })
        expect(response.body).to include('Title is too short')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'posts#destroy' do
    it 'should destroy corrent post from database' do
      expect do
        delete :destroy, params: auth_headers.merge(id: created_post)
      end.to change(Post, :count).by(0)
    end

    it "shouldn't delete post that doesn't belong to you and send correct error message and status with response" do
      someone_else_post = create(:post, user: create(:user))
      expect do
        delete :destroy, params: auth_headers.merge(id: someone_else_post)
      end.to change(Post, :count).by(0)
      expect(response.body).to include("doesn't belong to you.")
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'when user not authorized' do
    let(:authentication_error_message) { 'You need to sign in or sign up before continuing.' }
    context 'posts#index' do
      it 'should send a correct error message and status with response' do
        get :index
        expect(response.body).to include(authentication_error_message)
        expect(response).to have_http_status(401)
      end
    end
    context 'posts#show' do
      it 'should send a correct error message and status with response' do
        get :show, params: { id: created_post }
        expect(response.body).to include(authentication_error_message)
        expect(response).to have_http_status(401)
      end
    end
    context 'posts#create' do
      it "shouldn't create a new post and send response with correct error message and status" do
        expect do
          post :create, params: { post: { title: 'new title', body: 'new body' } }
        end.to change(Post, :count).by(0)
        expect(response.body).to include(authentication_error_message)
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'posts#update' do
      it "shouldn't update post and send changed post and status with response" do
        put :update, params: { id: created_post, post: { title: 'updated', body: 'updated' } }
        created_post_after_request = Post.find(created_post.id)
        expect(created_post_after_request.updated_at).to eq(created_post.updated_at)
        expect(response.body).to include(authentication_error_message)
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'posts#destroy' do
      it "shouldn't delete post and send correct error message and status with response" do
        expect do
          delete :destroy, params: { id: created_post }
        end.to change(Post, :count).by(1)
        expect(response.body).to include(authentication_error_message)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
