require 'rails_helper'

RSpec.describe "Users", type: :request do


  let(:current_user) { create(:user) }
  let(:new_user) { {"email" => "email@example.com", "password" => "password" }}
  let(:auth_valid_headers) { current_user.create_new_auth_token('client').merge("ACCEPT" => "application/json") }
  let(:authentication_errors) { "You need to sign in or sign up before continuing." }
  let(:invalid_headers) { {"ACCEPT" => "application/json"} }


  # Get All Users
  describe "GET /users" do
    context "with valid headers" do
        it "should return all users with correct count" do
          get users_url, headers: auth_valid_headers
            users_from_response = JSON.parse(response.body)["users"]
            expect(users_from_response.count).to eq(User.all.count)
        end

        it "should return correct status" do
          get users_url, headers: auth_valid_headers
          expect(response).to have_http_status(200)
        end
    end

    context "with invalid headers" do
      it "should return authentication errors" do
        get users_url, headers: invalid_headers
          response_error_message = JSON.parse(response.body)['errors'][0]
          expect(response_error_message).to include(authentication_errors)
      end

      it "should return all correct status" do
        get users_url, headers: invalid_headers
        expect(response).to have_http_status(401)
      end
    end
  end

  # Get User Profile
  describe "GET /user/profile" do
    context "with valid headers" do

      it "should return current user's data" do
        get user_profile_url, headers: auth_valid_headers
        user_from_response = JSON.parse(response.body)["user"]
        expect(user_from_response["email"]).to eq(current_user.email)
        expect(user_from_response["name"]).to eq(current_user.name)
        expect(user_from_response["sername"]).to eq(current_user.sername)
        expect(user_from_response).to include("posts", "comments")
      end

      it "should return correct status 200" do
        get user_profile_url, headers: auth_valid_headers
        expect(response).to have_http_status(200)
      end

    end

    context "with invalid headers" do
      it "should return authentication errors" do
        get user_profile_url, headers: invalid_headers
        response_error_message = JSON.parse(response.body)['errors'][0]
        expect(response_error_message).to include(authentication_errors)
      end
      it "should return correct status" do
        get user_profile_url, headers: invalid_headers
        expect(response).to have_http_status(401)
      end
    end

  end

  # Register new Account
  describe "POST /auth" do
    context "with valid params" do
      it "should create a new Account" do
        post user_registration_url, params: new_user
        expect(response).to have_http_status(201)
      end

      it "should create new Account in DB" do
        
      end

      it "should return correct status" do
        
      end
    end

    context "with invalid params" do

      context "only with invalid email " do

        it "should return correct error message" do 
        end

        it "should return correct status" do
        end

        it "should not create a new Account" do
        end

      end

      context "only with invalid password " do

        it "should return correct error message" do 
        end

        it "should return correct status" do
        end

        it "should not create a new Account" do
        end

      end

      context "with invalid email and password " do

        it "should return correct error message" do 
        end

      end

    end

  end

  # User Sign In
  describe "POST /auth/sign_in" do
  end

  # User Sign Out
  describe "DELETE /auth/sign_out" do
  end

  # User updates params
  describe "PATCH /users/:id" do
  end

  # Destroy User from DB
  describe "DELETE /users/:id" do
  end

end
