class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]

  before_filter :authenticate_user!

  def index
    if current_user.is_publisher?
      @posts = current_user.posts.ordered
      render 'index_publisher'
    else
      @posts = Post.joins(:post_transitions).where('post_transitions.to_state = ?', 'paid').ordered
      render 'index_editor'
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to edit_post_path(@post, anchor: 'payment-form'), notice: 'Post was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @post.update(post_params)
      redirect_to edit_post_path(@post, anchor: 'payment-form'), notice: 'Post was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @post.destroy

    redirect_to posts_path
  end

  private
    def set_post
      @post = Post.for_user(current_user).find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :body)
    end
end
