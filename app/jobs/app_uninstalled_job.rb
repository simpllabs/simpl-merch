class AppUninstalledJob < ProgressJob::Base
  def initialize(domain, params)
    @domain = domain
    @params = params
  end

  def perform
    #Since S3 is mega cheap, do nothing; if they re-install all their stuff will be there again
    begin

    rescue Exception => e
		  job_title = "app_uninstalled_job.rb"
	    log_data_1 = e.message
	    log_data_2 = e.backtrace

	    ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end
  end
end