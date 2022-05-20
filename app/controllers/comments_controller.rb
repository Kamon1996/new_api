# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show update destroy]
  before_action :authenticate_user!

  # POST /comments
  def create
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
      render status: :created
    else
      render json: @comment.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/:id
  def update
    if @comment.update(comment_params)
    else
      render json: @comment.errors.full_messages, status: :unprocessable_entity
    end
  end

  # DELETE /comments/:id
  def destroy
    if @comment.user_id == current_user.id
      @comment.destroy
      head :no_content
    else
      render json: 'Руки проч от чужого комментария!', status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.permit(:post_id, :body)
  end
end
