# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:current_user) { create(:user) }
  let(:auth_headers) { current_user.create_new_auth_token }

  describe 'users#index' do
    context 'when used valid headers' do
      it 'should send response with correct count of users and status' do
        get :index, params: auth_headers
        expect(json['users'].count).to eq(User.all.count)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'users#show_profile' do
    context 'when used valid headers' do
      it "should send correct user's data and status with response" do
        get :show_profile, params: auth_headers
        expect(json['email']).to eq(current_user.email)
        expect(json['name']).to eq(current_user.name)
        expect(json['sername']).to eq(current_user.sername)
        expect(json).to include('posts', 'comments')
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'when user not authorized' do
    let(:authentication_error_message) { 'You need to sign in or sign up before continuing.' }
    context 'users#index' do
      it 'should send correct error message and status with response' do
        get :index
        expect(response.body).to include(authentication_error_message)
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'users#show_profile' do
      it 'should send correct error message and status with response' do
        get :show_profile
        expect(response.body).to include(authentication_error_message)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
