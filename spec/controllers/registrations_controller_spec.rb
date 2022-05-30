# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviseTokenAuth::RegistrationsController, type: :controller do
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'registrations#create' do
    context 'when used valid params' do
      it 'should create a new account' do
        expect do
          post :create, params: { email: 'test@example.com', password: 'password' }
        end.to change(User, :count).by(1)
      end
      it 'should create correct account in database and send it with response' do
        post :create, params: { email: 'test@example.com', password: 'password', name: 'name', sername: 'sername' }
        expect(json['email']).to eq(request.params['email'])
        expect(json['name']).to eq(request.params['name'])
        expect(json['sername']).to eq(request.params['sername'])
      end
      it 'should send correct status with response' do
        post :create, params: { email: 'test@example.com', password: 'password' }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when used invalid params' do
      context 'when used invalid email ' do
        it 'should not create a new Account' do
          expect do
            post :create, params: { email: 'wrong_email', password: 'password' }
          end.to_not change(User, :count)
        end

        it 'should send correct error message and status with response' do
          post :create, params: { email: 'wrong_email', password: 'password' }
          expect(response.body).to include('Email is not an email')
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when used invalid password ' do
        it 'should not create a new Account' do
          expect do
            post :create, params: { email: 'test@example.com', password: 'abcde' }
          end.to_not change(User, :count)
        end

        it 'should send correct error message and status with response' do
          post :create, params: { email: 'test@example.com', password: '12' }
          expect(response.body).to include('Password is too short')
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
