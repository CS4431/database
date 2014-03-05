require 'rake/testtask'
require 'sinatra/activerecord'
require_relative 'db/schema'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

namespace :db do
  desc "Recreates a database based on the defined schema"
  task :recreate  do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                            database: 'db/books.sqlite')
    Schema.drop_tables
    Schema.create_db
  end
end

namespace :db do
  desc "Creates a database based on the defined schema"
  task :create do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                            database: 'books.sqlite')
    Schema.create_db
  end
end
