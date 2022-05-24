# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/posts', type: :request do
  let(:current_user) { create(:user) }
  let(:created_post) { create(:post, user: current_user) }
  let(:auth_headers) { current_user.create_new_auth_token }
  let(:new_post) { build(:post) }
  let(:new_post_invalid) { build(:post, title: '1', body: '1') }

  describe 'GET /index' do
    context 'with valid headers' do
      it 'renders a correct status' do
        get posts_url, headers: auth_headers
        expect(response).to have_http_status(200)
      end

      it 'renders correct count of Posts' do
        create_list(:post, 10)
        get posts_url, headers: auth_headers
        posts_from_response = JSON.parse(response.body)['posts']
        expect(posts_from_response.count).to eq(Post.all.count)
      end
    end

    context 'with no-auth headers' do
      it 'renders a not auth error message' do
        get posts_url
        expect(response).to have_http_status(401)
        expect(response.body).to include('You need to sign in or sign up before continuing')
      end
    end
  end

  describe 'GET /show' do
    context 'with valid headers' do
      context 'should send response with correct status' do
        it 'renders a correct status' do
          get post_url(created_post), headers: auth_headers
          expect(response).to have_http_status(200)
        end

        it 'should send response with correct post' do
          get post_url(created_post), headers: auth_headers
          response_post_id = JSON.parse(response.body)['id']
          expect(response_post_id).to eq(created_post.id)
        end
      end

      context 'with non-existed post' do
        it 'renders a correct status' do
          get post_url(-1), headers: auth_headers
          expect(response).to have_http_status(:not_found)
        end

        it 'renders a correct error' do
          get post_url(-1), headers: auth_headers
          expect(response.body).to include("Couldn't find")
        end
      end
    end

    context 'with invalid headers' do
      it 'renders a correct error' do
        get post_url(created_post)
        expect(response).to have_http_status(401)
        expect(response.body).to include('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Post in DB' do
        expect do
          post posts_url, params: { post: new_post.as_json }, headers: auth_headers
        end.to change(Post, :count).by(1)
      end

      it 'renders a correct status' do
        post posts_url, params: { post: new_post.as_json }, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it 'renders back created Post' do
        post posts_url, params: { post: new_post.as_json }, headers: auth_headers
        post_from_response = JSON.parse(response.body)
        expect(post_from_response['title']).to eq(new_post['title'])
        expect(post_from_response['body']).to eq(new_post['body'])
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Post' do
        expect do
          post posts_url,
               params: { post: new_post_invalid.as_json }, headers: auth_headers
        end.to change(Post, :count).by(0)
      end

      it 'renders a correct status' do
        post posts_url,
             params: { post: new_post_invalid.as_json }, headers: auth_headers
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      it 'updates the requested post' do
        expect do
          put post_url(created_post),
              params: { post: new_post.as_json }, headers: auth_headers
        end.to change(Post, :count).by(1)
        post_from_response = JSON.parse(response.body)
        expect(post_from_response['title']).to eq(new_post['title'])
        expect(post_from_response['body']).to eq(new_post['body'])
        expect(post_from_response['id']).to eq(created_post['id'])
        expect(post_from_response['updated_at']).to_not eq(created_post['updated_at'])
      end

      it 'renders a correct status' do
        patch post_url(created_post),
              params: { post: new_post.as_json }, headers: auth_headers
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid parameters' do
      it 'should send response with any errors' do
        patch post_url(created_post),
              params: { post: new_post_invalid.as_json }, headers: auth_headers
        expect(response).to have_http_status(422)
        expect(response.body).not_to be_empty
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'should destroy corrent post from DB' do
      expect do
        delete post_url(created_post), headers: auth_headers
      end.to change(Post, :count).by(0)
    end

    it "won't let you delete a post that isn't yours" do
      someone_else_post = create(:post, user: create(:user))
      expect do
        delete post_url(someone_else_post), headers: auth_headers
      end.to change(Post, :count).by(0)
      expect(response.body).to_not be_empty
    end
  end
end
