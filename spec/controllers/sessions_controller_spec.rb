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
      it 'should send valid auth token and status with response' do
        post :create, params: { email: current_user.email, password: current_user.password }
        client = response.headers['client']
        token = response.headers['access-token']
        current_user_in_data_base = User.find(current_user.id)
        expect(response.has_header?('access-token')).to eq(true)
        expect(current_user_in_data_base.valid_token?(token, client)).to be_truthy
        expect(response).to have_http_status(200)
      end
    end

    context 'when used invalid params' do
      it 'should send correct message and status with response' do
        post :create, params: { email: current_user.email, password: '12' }
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
