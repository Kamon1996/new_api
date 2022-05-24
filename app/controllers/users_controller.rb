# frozen_string_literal: true

class UsersController < ApplicationController
  # GET /users
  def index
    @users = User.all
  end

  # GET /user/profile
  def show; end
end
