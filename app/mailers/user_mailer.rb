class UserMailer < ActionMailer::Base
  default from: 'Gamer Police <gamer@police.dept>' #WEEWOO

  def confirm_email(user, email)
    @uuid = SecureRandom.hex
    set_cache("email.#{user.id}", @uuid, 1.month)
    mail(:to => email, :subject => 'Confirm your email on the #{ORG::NAME}')
  end

  def notify_purchase(user, info)
    @user = user
    # todo
  end
end
