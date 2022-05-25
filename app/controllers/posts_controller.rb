# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]
  before_action :check_author, only: %i[update destroy]

  # GET /posts
  def index
    @posts = Post.all
  end

  # GET /posts/1
  def show; end

  # POST /posts
  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    if @post.save
    else
      render json: @post.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
    else
      render json: @post.errors.full_messages, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def check_author
    render json: "Post dosn't belong to you.", status: :unprocessable_entity if @post.user_id != current_user.id
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :body)
  end
end
