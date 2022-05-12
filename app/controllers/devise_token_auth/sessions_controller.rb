class DeviseTokenAuth::SessionsController < ApplicationController

  before_action :authenticate_user!, except: [:create]

  def create
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      client = request.headers['client']
      new_auth_header = user.create_new_auth_token(client)
      response.headers.merge!(new_auth_header)
      render json: {user: user, headers: response.headers}, status: :created
    else
      render json: "Invalid password or email" , status: :unprocessable_entity
    end
  end

  def destroy
    client = request.headers['client']
    user = User.find(current_user.id)
    user.tokens[client] = ''
    head :no_content
  end

  private

  def user_params
    params.permit(:email, :password)
  end

end
