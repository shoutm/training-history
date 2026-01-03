class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create, :failure ]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_or_create_from_omniauth(auth_hash)
    session[:user_id] = user.id
    redirect_to root_path, notice: "Logged in as #{user.name}"
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out"
  end

  def failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end
end
