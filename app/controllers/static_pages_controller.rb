class StaticPagesController < ApplicationController

  def home
    if user_signed_in? and current_user.is_publisher?
      redirect_to publisher_intro_path
    end
  end

  def publisher_intro
  end

end
