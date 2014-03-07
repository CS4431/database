require 'sinatra/activerecord'

# Define all operations for creating and modifying the database schema
module Schema

  # Drops all database tables
  def Schema.drop_tables
    ActiveRecord::Schema.define do
      drop_table :buy
      drop_table :contact
      drop_table :course
      drop_table :course_book 
      drop_table :department
      drop_table :edition
      drop_table :edition_group
      drop_table :sell
      drop_table :user
      drop_table :verification
    end
  end
  
  # Creates the database tables based on the defined schema
  def Schema.create_db
    ActiveRecord::Schema.define do
      # buy table
      create_table :buy do |t|
        t.integer :user_id, null: false
        t.integer :edition_id, null: false
        t.datetime :start_date
        t.datetime :end_date
      end
      # contact table
      create_table :contact do |t|
        t.integer :contactor_id, null: false
        t.integer :listing_id, null: false
        t.datetime :date, null: false
      end
      # course table
      create_table :course do |t|
        t.string :title, null: false
        t.string :code, null: false
        t.string :section, null: false
        t.string :instructor
        t.string :term
        t.integer :department_id, null: false
      end
      # course_book table
      create_table :course_book do |t|
        t.integer :course_id, null: false
        t.integer :edition_id, null: false
      end
      # department table
      create_table :department do |t|
        t.string :name, null: false
        t.string :code, null: false
      end
      # edition table
      create_table :edition do |t|
        t.integer :isbn, null: false
        t.integer :edition_group_id, null: false
        t.string :author
        t.integer :edition
        t.string :cover
        t.string :image
      end
      # edition_group table
      create_table :edition_group do |t|
        t.string :title, null: false
      end
      # sell table
      create_table :sell do |t|
        t.integer :user_id, null: false
        t.integer :edition_id, null: false
        t.integer :price, null: false
        t.datetime :start_date, null: false
        t.datetime :end_date, null: false
      end
      # user table
      create_table :user do |t|
        t.string :email, null: false
        t.string :password, null: false
        t.boolean :verified, null: false
      end
      # verification table
      create_table :verification do |t|
        t.string :code, null: false
        t.integer :user_id, null: false
        t.datetime :end_date, null: false
      end
    end
  end
end
