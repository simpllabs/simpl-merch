# Require the full rails environment if needed
require './config/boot'
require './config/environment'

include Clockwork

handler do |job|
  puts "Running #{job}"
end

# Define the jobs
every(1.day, 'clean_tmp.job', :at => '00:00', :tz => 'MST') { Delayed::Job.enqueue CleanTmpJob.new }

every(1.day, 'midnight.job', :at => '00:00', :tz => 'MST') { Delayed::Job.enqueue ProcessOrdersJob.new}

#every(5.hours, 'process_test.job') { Delayed::Job.enqueue ProcessOrdersJob.new }
