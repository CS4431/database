require_relative './buy'
require_relative './contact'
require_relative './course'
require_relative './course_book'
require_relative './department'
require_relative './edition'
require_relative './edition_group'
require_relative './mailhandler'
require_relative './sell'
require_relative './user'
require_relative './verification'
require_relative './token'

# Stores and returns the tables that are available for searching, as well as the related fields
class Search
	@@tables = {
		:book => {:table => EditionGroup, :fields => ["title"]},
		:course => {:table => Course, :fields => ["title", "code", "section", "instructor", "term"]},
		:department => {:table => Department, :fields => ["name", "code"]},
	}

	# Returns the @@tables instance variable, containing the table & field data for searching the database via the API
	def self.tables
		@@tables
	end
end