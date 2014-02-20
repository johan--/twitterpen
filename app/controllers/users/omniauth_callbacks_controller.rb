class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    auth = env["omniauth.auth"]
    role = params[:role].to_s

    # Check for a valid role
    unless ['publisher', 'editor'].include? role
      redirect_to new_user_session_path, alert: 'Invalid role' and return
    end

    user = User.find_for_twitter_oauth(request.env["omniauth.auth"], role, current_user)
    if user.persisted?
      # Check if the user is trying to login as something else
      if user.roles.first.name != role
        redirect_to new_user_session_path, alert: "You are already #{user.roles.first.name}, you cannot login as #{role}. Please get in touch with administrator if you would like to change your profile." and return
      end

      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: 'twitter'
      sign_in_and_redirect user, event: :authentication and return
    else
      session["devise.twitter_uid"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url and return
    end
  end
end
