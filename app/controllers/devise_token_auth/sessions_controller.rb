# frozen_string_literal: true

module DeviseTokenAuth
  class SessionsController < ApplicationController
    before_action :authenticate_user!, except: [:create]

    def create
      user = User.find_by(email: params[:email].downcase)
      if user&.valid_password?(params[:password])
        client = request.headers['client']
        new_auth_header = user.create_new_auth_token(client)
        response.headers.merge!(new_auth_header)
        render json: { user: user, headers: response.headers }
      else
        render json: 'Invalid password or email', status: :unprocessable_entity
      end
    end

    def destroy
      client = request.headers['client']
      user = User.find(current_user.id)
      user.create_new_auth_token(client)
      head :no_content
    end

    private

    def user_params
      params.permit(:email, :password)
    end
  end
end
