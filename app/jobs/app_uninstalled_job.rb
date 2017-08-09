class AppUninstalledJob < ProgressJob::Base
  def initialize(domain, params)
    @domain = domain
    @params = params
  end

  def perform
    #Since S3 is mega cheap, do nothing; if they re-install all their stuff will be there again
  end
end