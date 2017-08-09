class InstalledAppJob < ActiveJob::Base

  def perform



  	#Send out welcome email
    FirstInstallMailer.welcome_email.deliver_now
  end
end