class Contact < MailForm::Base
  attribute :username, :validate => true
  attribute :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :subject, :validate => true
  attribute :about, :validate => true
  attribute :message
  attribute :nickname, :captcha => true

  # Generates headers for sent mail based on attributes.
  def headers
    {
        :subject => "[#{about}] #{subject}",
        :to => '#{ORG::EMAIL}',
        :from => %("#{username}" <#{email}>)
    }
  end
end