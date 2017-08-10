# Require the full rails environment if needed
require './config/boot'
require './config/environment'

include Clockwork

handler do |job|
  puts "Running #{job}"
end

# Define the jobs
every(60.seconds, 'test.job') {Delayed::Job.enqueue ProcessOrdersJob.new }

every(6.hours, 'clean_tmp.job') { Delayed::Job.enqueue CleanTmpJob.new}

every(1.day, 'midnight.job', :at => '00:00', :tz => 'MST') { Delayed::Job.enqueue ProcessOrdersJob.new}

