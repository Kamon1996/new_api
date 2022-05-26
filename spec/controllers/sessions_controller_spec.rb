# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviseTokenAuth::SessionsController, type: :controller do
  let(:current_user) { create(:user) }
  let(:auth_headers) { current_user.create_new_auth_token }
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'sessions#create' do
    context 'when used valid params' do
      it 'should create a new auth token for currently client' do
        post :create, params: auth_headers.merge(email: current_user.email, password: current_user.password)
        client = auth_headers['client']
        current_user_in_db = User.find_by(email: current_user.email)
        expect(current_user_in_db.tokens[client]).to_not be_empty
      end

      it 'should send valid auth token and status with response' do
        post :create, params: auth_headers.merge(email: current_user.email, password: current_user.password)
        client = response.headers['client']
        token = response.headers['access-token']
        current_user_in_db = User.find_by(email: current_user.email)
        expect(response.has_header?('access-token')).to eq(true)
        expect(current_user_in_db.valid_token?(token, client)).to be_truthy
        expect(response).to have_http_status(200)
      end
    end

    context 'when used invalid params' do
      it 'should send any correct message and status with response' do
        post :create, params: auth_headers.merge(email: current_user.email, password: '12')
        expect(response.body).to include('Invalid password or email')
        expect(response).to have_http_status(422)
      end
    end
  end

  # User Sign Out
  describe 'sessions#destroy' do
    context 'when used auth valid headers' do
      it "should invalidate user's authentication token and send correct status with response" do
        delete :destroy, params: auth_headers
        client = auth_headers['client']
        token = auth_headers['access_token']
        expect(current_user.valid_token?(token, client)).to be_falsey
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
