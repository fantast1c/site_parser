set :output, '../log/cron.log'
set :environment, 'development'
every 24.hours do
  rake 'sites:parse_sources'
end
