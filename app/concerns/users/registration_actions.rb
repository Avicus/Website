# User controller actions that handle registration.
module Users::RegistrationActions

  def register

  end

  def registration_start
    @user = User.find_by_username(params[:username])

    redirect_if_fail(!@user.nil?, '/users/register', 'This user is does not exist. You must log into the #{ORG::NAME} at least once.'); return if performed?

    @verify_key = rand.to_s[2..5]
    @user.update(:verify_key => @verify_key, :verify_key_success => false)

    @reg_verify = rand.to_s[2..5]

    set_cache "registration.#{@user.id}", @reg_verify, 15.minutes

    render :register
  end

  def registration_status
    user = User.find_by_id(params[:user_id])
    render :json => {:success => user.verify_key_success?}
  end

  def registration_success
    user = User.find_by_id(params[:user_id])

    redirect_if_fail(get_cache("registration.#{user.id}") == params[:reg_verify], '/', 'Registration session has expired. Please try again.'); return if performed?
    redirect_if_fail(user.verify_key_success, '/', 'Registration could not be verified. Please try again.'); return if performed?

    @temp_pass = SecureRandom.hex(8)
    password = Digest::MD5.hexdigest($avicus['salt'] + @temp_pass)
    user.update(:password => password, :password_secure => nil, :verify_key_success => false, :verify_key => nil)
    render :register
  end

end
