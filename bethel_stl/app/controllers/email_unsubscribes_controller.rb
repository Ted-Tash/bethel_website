class EmailUnsubscribesController < ApplicationController
  # The signed, purpose-scoped token authorizes only suppression. Required for
  # RFC 8058 one-click requests from mail providers without a browser session.
  skip_forgery_protection only: :create
  before_action :verify_token

  def show
    # GET is intentionally read-only: link scanners must not unsubscribe people.
  end

  def create
    EmailSuppression.suppress!(@email)
    render :create
  end

  private

  def verify_token
    @email = EmailSuppression.email_from_token(params[:token])
    head :not_found unless @email.is_a?(String) && @email.match?(URI::MailTo::EMAIL_REGEXP)
  end
end
