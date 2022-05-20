require 'rails_helper'

RSpec.describe "Users", type: :request do


  let(:current_user) { create(:user) }
  let(:new_user) { build(:user) }
  let(:client) { generate_client }
  let(:valid_headers) { { "ACCEPT" => "application/json", "client" => client } }
  let(:auth_valid_headers) { current_user.create_new_auth_token(client).merge("ACCEPT" => "application/json", "client" => client) }
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
        response_error_message = JSON.parse(response.body)['errors']
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
        expect {
          post user_registration_url, params: { email: new_user.email, password: new_user.password }
      }.to change(User, :count).by(1)
        expect(response).to have_http_status(201)
      end

      it "should return correct status" do
        post user_registration_url, params: { email: new_user.email, password: new_user.password }
        expect(response).to have_http_status(201)
      end
    end

    context "with invalid params" do

      context "only with invalid email " do

        it "should return any error message" do
          post user_registration_url, params: { email: "wrong_email", password: new_user.password }
          error_from_response = JSON.parse(response.body)["error"]
          expect(error_from_response).to_not be_empty
        end

        it "should return correct status" do
          post user_registration_url, params: { email: "wrong@email", password: new_user.password }
          expect(response).to have_http_status(422)
        end

        it "should not create a new Account" do
          expect {
            post user_registration_url, params: { email: "wrongemail.ru", password: new_user.password }
        }.to_not change(User, :count)
        end

      end

      context "only with invalid password " do

        it "should return any error message" do 
          post user_registration_url, params: { email: new_user.email, password: "123" }
          error_from_response = JSON.parse(response.body)["error"]
          expect(error_from_response).to_not be_empty
        end

        it "should return correct status" do
          post user_registration_url, params: { email: new_user.email, password: "" }
          expect(response).to have_http_status(422)
        end

        it "should not create a new Account" do
          expect {
            post user_registration_url, params: { email: new_user.email, password: "abcde" }
        }.to_not change(User, :count)
        end

      end

    end

  end

  # User Sign In
  describe "POST /auth/sign_in" do
    context "with valid params" do
      it "should create a new auth token for currently client" do
        post user_session_url, params: { email: current_user.email, password: current_user.password }, headers: valid_headers
        client = valid_headers["client"]
        current_user_in_DB = User.find_by(email: current_user.email)
        expect(current_user_in_DB.tokens[client]).to_not be_empty
      end

      it "should send valid auth token with response" do
        post user_session_url, params: { email: current_user.email, password: current_user.password }, headers: valid_headers
        client = response.headers["client"]
        token = response.headers["access-token"]
        current_user_in_DB = User.find_by(email: current_user.email)
        expect(response.has_header?('access-token')).to eq(true)
        expect(current_user_in_DB.valid_token?(token, client)).to be_truthy
      end

      it "should send a correct response status" do
        post user_session_url, params: { email: current_user.email, password: current_user.password }, headers: valid_headers
        expect(response).to have_http_status(200)
      end
    end

    context "with invalid params" do
      it "should not create a new auth token for currently client" do
        post user_session_url, params: { email: current_user.email, password: "1" }, headers: valid_headers
        client = valid_headers["client"]
        current_user_in_DB = User.find_by(email: current_user.email)
        expect(current_user_in_DB.tokens).to_not include(client)
      end

      it "should sends any error message with response" do
        post user_session_url, params: { email: current_user.email, password: "12" }, headers: valid_headers
        error_from_response = response.body
        expect(error_from_response).to_not be_empty
      end

      it "should send a correct response status" do
        post user_session_url, params: { email: current_user.email, password: "123" }, headers: valid_headers
        expect(response).to have_http_status(422)
      end
    end
  end

  # User Sign Out
  describe "DELETE /auth/sign_out" do
    context "with auth valid headers" do
      it "should invalidate the user's authentication token" do
        delete destroy_user_session_url, headers: auth_valid_headers
        client = auth_valid_headers["client"]
        token = auth_valid_headers["access_token"]
        expect(current_user.valid_token?(token, client)).to be_falsey
      end
    end
  end

  # # User updates params
  # describe "PATCH /users/:id" do
  #   context "with auth valid headers and params" do
  #     it "should update user's params" do
  #     end

  #     it "should reutrn a correct status" do
  #     end

  #   end
  # end

  # # Destroy User from DB
  # describe "DELETE /users/:id" do
  #   context "with auth valid headers" do
  #     it "should destroy user from DB" do
  #     end
  #   end
  # end

end
