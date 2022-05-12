class DeviseTokenAuth::RegistrationsController < ApplicationController

  before_action :authenticate_user!, except: [:create]

  def create
    user = User.new(user_params)
    if user.save
      render json: { user: user.as_json }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end

  end

  private

  def user_params
    params.permit(:email, :password, :name, :sername, :nickname)
  end

end
