class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
  rescue_from RubyBox::AuthError, with: :deny_access

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  private

  def deny_access
    if current_user
      account = current_user.linked_accounts.where(provider: "box").first
      flash[:error] = "Authentication expired: #{account.provider}"
      account.destroy
    else
      flash[:error] = "Authentication expired:"
    end
    redirect_to root_path
  end
end
