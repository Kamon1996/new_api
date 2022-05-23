# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:current_user) { create(:user) }
  let(:new_user) { build(:user) }
  let(:auth_headers) { current_user.create_new_auth_token }
  let(:authentication_error_message) { 'You need to sign in or sign up before continuing.' }

  # Get All Users
  describe 'GET /users' do
    context 'with valid headers' do
      it 'should return all users with correct count' do
        get users_url, headers: auth_headers
        users_from_response = JSON.parse(response.body)['users']
        expect(users_from_response.count).to eq(User.all.count)
      end

      it 'should return correct status' do
        get users_url, headers: auth_headers
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid headers' do
      it 'should return authentication errors' do
        get users_url
        expect(response.body).to include(authentication_error_message)
      end

      it 'should return all correct status' do
        get users_url
        expect(response).to have_http_status(401)
      end
    end
  end

  # Get User Profile
  describe 'GET /user/profile' do
    context 'with valid headers' do
      it "should return current user's data" do
        get user_profile_url, headers: auth_headers
        user_from_response = JSON.parse(response.body)['user']
        expect(user_from_response['email']).to eq(current_user.email)
        expect(user_from_response['name']).to eq(current_user.name)
        expect(user_from_response['sername']).to eq(current_user.sername)
        expect(user_from_response).to include('posts', 'comments')
      end

      it 'should return correct status' do
        get user_profile_url, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid headers' do
      it 'should return authentication errors' do
        get user_profile_url
        expect(response.body).to include(authentication_error_message)
      end
      it 'should return correct status' do
        get user_profile_url
        expect(response).to have_http_status(401)
      end
    end
  end

  # Register new Account
  describe 'POST /auth' do
    context 'with valid params' do
      it 'should create a new Account' do
        expect do
          post user_registration_url, params: { email: new_user.email, password: new_user.password }
        end.to change(User, :count).by(1)
      end
      it 'should return correct status' do
        post user_registration_url, params: { email: new_user.email, password: new_user.password }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      context 'only with invalid email ' do
        it 'should not create a new Account' do
          expect do
            post user_registration_url, params: { email: 'wrongemail.ru', password: new_user.password }
          end.to_not change(User, :count)
        end

        it 'should return any error message' do
          post user_registration_url, params: { email: 'wrong_email', password: new_user.password }
          error_from_response = JSON.parse(response.body)['error']
          expect(error_from_response).to_not be_empty
        end

        it 'should return correct status' do
          post user_registration_url, params: { email: 'wrong@email', password: new_user.password }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'only with invalid password ' do
        it 'should return any error message' do
          post user_registration_url, params: { email: new_user.email, password: '123' }
          error_from_response = JSON.parse(response.body)['error']
          expect(error_from_response).to_not be_empty
        end

        it 'should return correct status' do
          post user_registration_url, params: { email: new_user.email, password: '' }
          expect(response).to have_http_status(422)
        end

        it 'should not create a new Account' do
          expect do
            post user_registration_url, params: { email: new_user.email, password: 'abcde' }
          end.to_not change(User, :count)
        end
      end
    end
  end

  # User Sign In
  describe 'POST /auth/sign_in' do
    context 'with valid params' do
      it 'should create a new auth token for currently client' do
        post user_session_url, params: { email: current_user.email, password: current_user.password },
                               headers: auth_headers
        client = auth_headers['client']
        current_user_in_db = User.find_by(email: current_user.email)
        expect(current_user_in_db.tokens[client]).to_not be_empty
      end

      it 'should send valid auth token with response' do
        post user_session_url, params: { email: current_user.email, password: current_user.password },
                               headers: auth_headers
        client = response.headers['client']
        token = response.headers['access-token']
        current_user_in_db = User.find_by(email: current_user.email)
        expect(response.has_header?('access-token')).to eq(true)
        expect(current_user_in_db.valid_token?(token, client)).to be_truthy
      end

      it 'should send a correct response status' do
        post user_session_url, params: { email: current_user.email, password: current_user.password },
                               headers: auth_headers
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid params' do
      it 'should sends any error message with response' do
        post user_session_url, params: { email: current_user.email, password: '12' }, headers: auth_headers
        expect(response.body).to_not be_empty
      end

      it 'should send a correct response status' do
        post user_session_url, params: { email: current_user.email, password: '123' }, headers: auth_headers
        expect(response).to have_http_status(422)
      end
    end
  end

  # User Sign Out
  describe 'DELETE /auth/sign_out' do
    context 'with auth valid headers' do
      it "should invalidate the user's authentication token" do
        delete destroy_user_session_url, headers: auth_headers
        client = auth_headers['client']
        token = auth_headers['access_token']
        expect(current_user.valid_token?(token, client)).to be_falsey
      end
    end
  end
end
