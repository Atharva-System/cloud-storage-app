class HomeController < ApplicationController
  def index
    if current_user
      @link_accounts = current_user.linked_accounts
    else
      render :partial=> "/sessions/sign_in", :layout => "application"
    end
  end

  def routing_error
    redirect_to root_path
  end
end
