class AppInstalledJob < ApplicationJob

  def perform(shop_domain)

  	

  	#Send out welcome email
    FirstInstallMailer.welcome_email(shop_domain).deliver_now
  end
end