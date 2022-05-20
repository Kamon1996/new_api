# frozen_string_literal: true

class UsersController < ApplicationController
  # GET /users
  def index
    @users = User.all
    render json: { users: @users }, status: :ok
  end

  # GET /user/profile
  def show; end


  # PATCH/PUT /users/1
  # def update
  #   if user.update
  #   else
  #     render json: user.errors.full_messages, status: :unprocessable_entity
  #   end
  # end

  # DELETE /users/1
  # def destroy
  #   if user.destroy
  #     head :no_content
  #   else
  #     render json: user.errors.full_messages, status: :unprocessable_entity
  #   end
  # end

  private

  def user
    @user ||= User.find(params[:id])
  end
end
