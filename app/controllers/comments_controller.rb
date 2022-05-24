# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show update destroy]
  before_action :check_author, only: %i[update destroy]

  # POST /comments
  def create
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
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
    @comment.destroy
    head :no_content
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def check_author
    render json: "Comment dosn't belong to you.", status: :unprocessable_entity if @comment.user_id != current_user.id
  end

  def comment_params
    params.permit(:post_id, :body)
  end
end
