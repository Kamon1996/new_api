# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviseTokenAuth::RegistrationsController, type: :controller do
  let(:new_user) { build(:user) }
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'registrations#create' do
    context 'with valid params' do
      it 'should create a new Account' do
        expect do
          post :create, params: new_user.as_json.merge(password: new_user.password)
        end.to change(User, :count).by(1)
      end
      it 'should create correct Account in database' do
          post :create, params: new_user.as_json.merge(password: new_user.password)
          created_user = User.find_by(email: new_user.email)
          expect(created_user.email).to eq(new_user.email)
          expect(created_user.name).to eq(new_user.name)
          expect(created_user.sername).to eq(new_user.sername)
          expect(created_user.nickname).to eq(new_user.nickname)
      end
      it 'should return correct status' do
        post :create, params: new_user.as_json.merge(password: new_user.password)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      context 'only with invalid email ' do
        it 'should not create a new Account' do
          expect do
            post :create, params: { email: 'wrong_email', password: new_user.password }
          end.to_not change(User, :count)
        end

        it 'should return any error message' do
          post :create, params: { email: 'wrong_email', password: new_user.password }
          expect(json['error']).to_not be_empty
        end

        it 'should return correct status' do
          post :create, params: { email: 'wrong_email', password: new_user.password }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'only with invalid password ' do
        it 'should return any error message' do
          post :create, params: { email: new_user.email, password: '123' }
          expect(json['error']).to_not be_empty
        end

        it 'should return correct status' do
          post :create, params: { email: new_user.email, password: '' }
          expect(response).to have_http_status(422)
        end

        it 'should not create a new Account' do
          expect do
            post :create, params: { email: new_user.email, password: 'abcde' }
          end.to_not change(User, :count)
        end
      end
    end
  end
end
