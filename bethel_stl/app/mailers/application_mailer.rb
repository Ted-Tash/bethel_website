class ApplicationMailer < ActionMailer::Base
  default from: -> { EmailConfiguration.sender }
  layout "mailer"
end
