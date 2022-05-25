# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:current_user) { create(:user) }
  let(:created_post) { create(:post, user: current_user) }
  let(:auth_headers) { current_user.create_new_auth_token }

  describe 'posts#index' do
    context 'with valid headers' do
      it 'renders a correct status' do
        get :index, params: auth_headers
        expect(response).to have_http_status(200)
      end

      it 'renders correct count of Posts' do
        create_list(:post, 10)
        get :index, params: auth_headers
        expect(json['posts'].count).to eq(Post.all.count)
      end
    end
    context 'with no-auth headers' do
      it 'renders a not auth error message' do
        get :index
        expect(response).to have_http_status(401)
        expect(response.body).to include('You need to sign in or sign up before continuing')
      end
    end
  end

  describe 'posts#show' do
    context 'with valid headers' do
      context 'should send response with correct status' do
        it 'renders a correct status' do
          get :show, params: auth_headers.merge(id: created_post)
          expect(response).to have_http_status(200)
        end

        it 'should send response with correct post' do
          get :show, params: auth_headers.merge(id: created_post)
          expect(json['id']).to eq(created_post.id)
        end
      end

      context 'with non-existed post' do
        it 'renders a correct status' do
          get :show, params: auth_headers.merge(id: -1)
          expect(response).to have_http_status(:not_found)
        end

        it 'renders a correct error' do
          get :show, params: auth_headers.merge(id: -1)
          expect(response.body).to include("Couldn't find")
        end
      end
    end

    context 'with invalid headers' do
      it 'renders a correct error' do
        get :show, params: { id: created_post }
        expect(response).to have_http_status(401)
        expect(response.body).to include('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'posts#create' do
    context 'with valid parameters' do
      it 'creates a new Post in DB' do
        expect do
          post :create, params: auth_headers.merge(post: { title: 'new title', body: 'new body' })
        end.to change(Post, :count).by(1)
      end

      it 'renders a correct status' do
        post :create, params: auth_headers.merge(post: { title: 'new title', body: 'new body' })
        expect(response).to have_http_status(:ok)
      end

      it 'renders back created Post' do
        post :create, params: auth_headers.merge(post: { title: 'new title', body: 'new body' })
        expect(json['title']).to eq('new title')
        expect(json['body']).to eq('new body')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Post' do
        expect do
          post :create, params: auth_headers.merge(post: { title: '1', body: '1' })
        end.to change(Post, :count).by(0)
      end

      it 'renders a correct status' do
        post :create, params: auth_headers.merge(post: { title: '', body: '' })
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'posts#update' do
    context 'with valid parameters' do
      it 'updates the requested post' do
        expect do
          put :update, params: auth_headers.merge(id: created_post, post: { title: 'updated', body: 'updated' })
        end.to change(Post, :count).by(1)
        expect(json['title']).to eq('updated')
        expect(json['body']).to eq('updated')
        expect(json['id']).to eq(created_post['id'])
        expect(json['updated_at']).to_not eq(created_post['updated_at'])
      end

      it 'renders a correct status' do
        put :update, params: auth_headers.merge(id: created_post, post: { title: 'updated', body: 'updated' })
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid parameters' do
      it 'should send response with any errors' do
        put :update, params: auth_headers.merge(id: created_post, post: { title: '1' })
        expect(response).to have_http_status(422)
        expect(response.body).not_to be_empty
      end
    end
  end

  describe 'posts#destroy' do
    it 'should destroy corrent post from DB' do
      expect do
        delete :destroy, params: auth_headers.merge(id: created_post)
      end.to change(Post, :count).by(0)
    end

    it "won't let you delete a post that isn't yours" do
      someone_else_post = create(:post, user: create(:user))
      expect do
        delete :destroy, params: auth_headers.merge(id: someone_else_post)
      end.to change(Post, :count).by(0)
      expect(response.body).to_not be_empty
    end
  end
end
