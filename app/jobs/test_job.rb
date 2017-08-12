class TestJob < ProgressJob::Base
  def initialize
  end

  def perform
        CsvOrdersMailer.csv_file_email(" ").deliver_now
  end
end