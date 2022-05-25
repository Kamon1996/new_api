# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviseTokenAuth::RegistrationsController, type: :controller do
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'registrations#create' do
    context 'with valid params' do
      it 'should create a new Account' do
        expect do
          post :create, params: { email: 'test@example.com', password: 'password' }
        end.to change(User, :count).by(1)
      end
      it 'should create correct Account in database' do
        post :create, params: { email: 'test@example.com', password: 'password', name: 'name', sername: 'sername' }
        expect(json['email']).to eq('test@example.com')
        expect(json['name']).to eq('name')
        expect(json['sername']).to eq('sername')
      end
      it 'should return correct status' do
        post :create, params: { email: 'test@example.com', password: 'password' }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      context 'only with invalid email ' do
        it 'should not create a new Account' do
          expect do
            post :create, params: { email: 'wrong_email', password: 'password' }
          end.to_not change(User, :count)
        end

        it 'should return any error message' do
          post :create, params: { email: 'wrong_email', password: 'password' }
          expect(json['error']).to_not be_empty
        end

        it 'should return correct status' do
          post :create, params: { email: 'wrong_email', password: 'password' }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'only with invalid password ' do
        it 'should return any error message' do
          post :create, params: { email: 'test@example.com', password: '12' }
          expect(json['error']).to_not be_empty
        end

        it 'should return correct status' do
          post :create, params: { email: 'test@example.com', password: '123' }
          expect(response).to have_http_status(422)
        end

        it 'should not create a new Account' do
          expect do
            post :create, params: { email: 'test@example.com', password: 'abcde' }
          end.to_not change(User, :count)
        end
      end
    end
  end
end
