# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found(message = nil)
    render json: message, status: 404
  end
end
