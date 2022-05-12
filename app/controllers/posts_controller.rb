class PostsController < ApplicationController

  # GET /posts
  def index
    @posts = Post.all
  end

  # GET /posts/1
  def show
    render json: post
  end

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
    if post.update(post_params)
      render json: post
    else
      render json: post.errors.full_messages, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    if post.destroy
      head :no_content
    else
      render json: post.errors.full_messages, status: :unprocessable_entity
    end
  end

  private
    def post
      @post ||= Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body)
    end
end
