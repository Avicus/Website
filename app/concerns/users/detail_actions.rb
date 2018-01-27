# User controller actions that handle the editing and updating of user details.
module Users::DetailActions
  def edit
    if @user != current_user && !@user.details.can_edit_any?(current_user)
      redirect_to @user.path
      return
    end

    @user_details = @user.details
    @cover_art = @user.details.cover_art
    @cover_art = 'castle.jpg' if @cover_art == nil

    @editable = editable_fields(@user_details)

    @colors = @user_details.usable_colors
    @icons = @user_details.usable_icons
    @icons['- NONE -'] = ''
  end

  def update
    @user_details = @user.details
    @editable = editable_fields(@user_details)
    @cover_art = @user.details.cover_art
    @cover_art = 'castle.jpg' if @cover_art == nil

    if params[:password] && @user == current_user
      unless @user.authenticate(params[:old])
        flash[:error] = 'Incorrect old password.'
        render :action => 'edit'
        return
      end

      if params[:confirm].blank? || params[:password] != params[:confirm]
        flash[:error] = 'Password confirmation did not match.'
        render :action => 'edit'
        return
      end

      if params[:password].size < 5
        flash[:error] = 'Your password must be at least 6 characters in length.'
        render :action => 'edit'
        return
      end

      password = params[:password]
      @user.password = nil
      @user.password_secure = BCrypt::Password.create(password)
      @user.save
      flash[:notice] = 'You have updated your password.'
      render :action => 'edit'
      return
    end

    if @user != current_user && !@user.details.can_edit_any?(current_user)
      redirect_to @user.path
      return
    end

    input = params[:user_detail]

    confirm = false

    if @user_details.email != input[:email]
      @user_details.email_status = 0
      if input[:email].presence
        UserMailer.confirm_email(current_user, input[:email]).deliver
        confirm = true
      end
    end

    @user_details.avatar = input[:avatar]
    @user_details.email = input[:email]
    @user_details.about = input[:about]
    @user_details.steam = input[:steam]
    @user_details.github = input[:github]
    @user_details.twitch = input[:twitch]
    @user_details.skype = input[:skype]
    @user_details.instagram = input[:instagram]
    @user_details.facebook = input[:facebook]
    @user_details.twitter = input[:twitter]
    @user_details.gender = input[:gender]
    @user_details.interests = input[:interests]

    colors = @user_details.usable_colors
    icons = @user_details.usable_icons

    icon = input[:custom_badge_icon]
    color = input[:custom_badge_color]

    color = nil unless colors.include?(color)
    icon = nil unless icons.has_value?(icon)

    @user_details.custom_badge_icon = icon
    @user_details.custom_badge_color = color

    if input[:cover_art] == 'Custom' && params[:upload_art].presence
      file = params[:upload_art]
      file_name = SecureRandom.hex + File.extname(file.original_filename)

      directory = 'public/uploads'
      # Deployment safe
      Dir.mkdir(directory) unless File.exists?(directory)

      path = File.join(directory, file_name)
      File.open(path, 'wb') { |f| f.write(file.read) }

      @user_details.cover_art = '/uploads/' + file_name
    elsif input[:cover_art] != 'Custom'
      @user_details.cover_art = input[:cover_art]
    end

    if @user_details.save
      @user.flush
      if confirm
        flash[:notice] = "A confirmation email has been sent to #{@user_details.email} and your profile has been updated."
      else
        flash[:notice] = 'You have updated your profile.'
      end
      redirect_to @user.path + '#about'
    else
      render :action => 'edit'
    end
  end
end
