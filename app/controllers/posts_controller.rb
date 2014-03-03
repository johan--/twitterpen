class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :compare]

  before_filter :authenticate_user!

  before_filter :set_section

  # FIXME: Replace the role checks below with cancan
  before_filter :check_role_editor, only: [:index_editor, :complete]
  before_filter :check_role_publisher, only: [:new, :create, :destroy, :compare]

  def index
    if current_user.is_publisher?
      @posts = current_user.posts.ordered
      render 'index_publisher'
    else
      @posts = Post.joins(:post_payments).where('post_payments.status = ? AND posts.editor_id IS NULL', $payments[:status][:paid]).ordered
      render 'index_pending'
    end
  end

  def index_editor
    @section = 'assigned_posts'
    @posts = Post.for_editor(current_user).with_transition.where("to_state != 'completed'")
  end

  def compare
    @post_original = @post.versions.where(event: :update).first.reify
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def edit
    if current_user.is_publisher?
      render 'edit_publisher'
    else
      @section = 'assigned_posts'
      render 'edit_editor'
    end
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
      if current_user.is_publisher?
        redirect_to edit_post_path(@post, anchor: 'payment-form'), notice: 'Post was successfully updated.' and return
      else
        redirect_to assigned_posts_path, notice: 'Your draft has been saved.' and return
      end
    else
      render action: 'edit'
    end
  end

  def destroy
    @post.destroy

    redirect_to posts_path
  end

  def assign
    post = Post.find(params[:id])
    if post.editor_id?
      redirect_to posts_path, alert: 'Sorry, this post has already been assigned.' and return
    else
      post.editor_id = current_user.id
      post.editor_assigned_at = Time.now
      if post.save
        post.state_machine.transition_to(:assigned)
        redirect_to posts_path, notice: 'Great, you can now edit the post.' and return
      else
        redirect_to posts and return
      end
    end
  end

  def complete
    post = Post.find(params[:id])
    if post.editor_id == current_user.id
      post.transition_to(:completed)
      redirect_to assigned_posts_path, notice: 'Great! Your post have been submitted back to the publisher'
    else
      redirect_to assigned_posts_path, alert: 'Sorry, you are not the editor of this post.'
    end
  end

  private
    def set_post
      if current_user.is_publisher?
        @post = Post.for_user(current_user).find(params[:id])
      else
        @post = Post.for_editor(current_user).find(params[:id])
      end
    end

    def post_params
      params.require(:post).permit(:title, :body)
    end

  protected
    def set_section
      @section = 'posts'
    end

    def check_role_editor
      unless current_user.is_editor?
        redirect_to posts_path, alert: 'Sorry, you have to be an editor to do this.' and return
      end
    end

    def check_role_publisher
      unless current_user.is_publisher?
        redirect_to posts_path, alert: 'Sorry, you have to be a publisher to do this.' and return
      end
    end
end
