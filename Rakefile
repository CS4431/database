require 'rake/testtask'
require 'sinatra/activerecord'
require_relative 'db/schema'
require_relative 'src/scraper'
require_relative 'test/fixtures'

Rake::TestTask.new do |t|
  DBHandler.establish_test_connection
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

namespace :db do
  desc "Recreates a database based on the defined schema"
  task :recreate  do
    DBHandler.establish_connection
    Schema.drop_tables
    Schema.create_db
  end
end

namespace :db do
  desc "Creates a database based on the defined schema"
  task :create do
    DBHandler.establish_connection
    Schema.create_db
  end
end

namespace :db do
  desc "Creates a database based on the defined schema"
  task :createtest do
    DBHandler.establish_test_connection
    Schema.create_db
  end
end

namespace :scraper do
  desc "Run the scraper"
  task :run do
    DBHandler.establish_connection
    url = "http://timetable.lakeheadu.ca/2013FW_UG_TBAY/courtime.html"
    Scraper.get_all_programs(url)
  end
end
