class SessionsController < ApplicationController
  skip_before_action(:check_bans)

  def self.permission_definition
  end

  def new
  end

  def create
    users = User.where(:username => params[:username])
    password = params[:password]
    remember_me = params[:remember_me].presence

    redirect_url = root_path
    if params[:goto].presence && !params[:goto].include?('sessions') && !params[:goto].include?('register')
      redirect_url = params[:goto]
    end

    users.each do |user|
      if user.authenticate(password)
        secure_user(user, password)

        set_current_user(user, remember_me)

        flash[:notice] = 'You have logged in successfully.'
        redirect_to(redirect_url)
        return
      end
    end

    flash[:error] = 'Incorrect username or password provided. Please try again.'
    render :new
  end

  def destroy
    clear_current_user
    redirect_to(root_url)
  end

  private

  def secure_user(user, password)
    # migrate to bcrypt password auth, for later use
    if user.password_secure.nil?
      user.update(:password => nil, :password_secure => BCrypt::Password.create(password))
    end
  end
end
