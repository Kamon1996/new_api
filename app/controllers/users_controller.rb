class UsersController < ApplicationController

  # GET /users
  # GET /users
  def index
    @users = User.all
  end

  # GET /user/profile
  def show
  end

  # PATCH/PUT /users/1
  def update
    if user.update
    else
      render json: user.errors.full_messages, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    if user.destroy
      head :no_content
    else
      render json: user.errors.full_messages, status: :unprocessable_entity
    end
  end

  private
    def user
      @user ||= User.find(params[:id])
    end

end
