class SessionsController < ApplicationController
  def create
    if user = User.find_by(:email => params[:user][:email]).try(:authenticate, params[:user][:password])
      session[:user_id] = user.id
      redirect_to root_url
    else
      @user = User.new(allowed_parameters)
      if @user.valid?
        @user.save
        session[:user_id] = @user.id
        redirect_to root_path
      else
        flash.now[:error] = @user.errors.full_messages.first
        # render :new
      end
      # flash.now[:error] = 'Email / password is invalid'
      # render :new
    end
  end

  def omniauth_callback
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def oauth_failure
    flash[:error] = t(:access_denied)
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:message] = t(:signout)
    redirect_to root_path
  end

  private

  def allowed_parameters
    params.require(:user).permit(:email, :password)
  end
end
