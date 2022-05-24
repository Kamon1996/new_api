# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:current_user) { create(:user) }
  let(:new_user) { build(:user) }
  let(:auth_headers) { current_user.create_new_auth_token }
  let(:authentication_error_message) { 'You need to sign in or sign up before continuing.' }

  # Get All Users
  describe 'users#index' do
    context 'with valid headers' do
      it 'should return all users with correct count' do
        get :index, params: auth_headers
        expect(json['users'].count).to eq(User.all.count)
      end

      it 'should return correct status' do
        get :index, params: auth_headers
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid headers' do
      it 'should return authentication errors' do
        get :index
        expect(response.body).to include(authentication_error_message)
      end

      it 'should return all correct status' do
        get :index
        expect(response).to have_http_status(401)
      end
    end
  end

  # Get User Profile
  describe 'users#show_profile' do
    context 'with valid headers' do
      it "should return current user's data" do
        get :show_profile, params: auth_headers
        user_from_response = json['user']
        expect(user_from_response['email']).to eq(current_user.email)
        expect(user_from_response['name']).to eq(current_user.name)
        expect(user_from_response['sername']).to eq(current_user.sername)
        expect(user_from_response).to include('posts', 'comments')
      end

      it 'should return correct status' do
        get :show_profile, params: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid headers' do
      it 'should return authentication errors' do
        get :show_profile
        expect(response.body).to include(authentication_error_message)
      end
      it 'should return correct status' do
        get :show_profile
        expect(response).to have_http_status(401)
      end
    end
  end
end
