class StaticPagesController < ApplicationController

  before_filter :set_section

  def home
    if user_signed_in?
      if current_user.is_publisher?
        redirect_to publisher_intro_path and return
      else
        redirect_to posts_path and return
      end
    end
  end

  def publisher_intro
  end

  protected
    def set_section
      @section = 'home'
    end
end
