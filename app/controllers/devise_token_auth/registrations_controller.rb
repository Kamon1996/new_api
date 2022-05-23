# frozen_string_literal: true

module DeviseTokenAuth
  class RegistrationsController < ApplicationController
    before_action :authenticate_user!, except: [:create]

    def create
      @user = User.new(user_params)
      if @user.save
        head :no_content
      else
        render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.permit(:email, :password, :name, :sername, :nickname)
    end
  end
end
