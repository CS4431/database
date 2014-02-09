require 'nokogiri'
require 'open-uri'
require 'logger.rb'
require_relative './db_handler'

# Handles all web scraping
module Scraper
  # Logs a message to scrape.log on scraping failure
  # @param error [String] the error message
  def Scraper.log(error)
    Logger.new('scrape.log', File::APPEND).fatal(error)
  end

  # Parses all links to timetables available on Course Timetables website of lakeheadu.ca
  # @param url [String] url of page to parse
  # @return [Array] links to all HTML documents, nil on failure
  def Scraper.get_all_timetables(url)
    begin
      page = Nokogiri::HTML(open(url))

      all_links = page.css('li').collect { |a| a.child }
      all_timetables = all_links.select { |a| a['href'].include? "courtime.html" }
      all_timetables.collect { |a| a['href'] }
    rescue
      self.log("get_all_timetables failed.")
      nil
    end
  end

  # Parses all links to courses available on Programs website of lakeheadu.ca
  # @param (see #get_all_timetables)
  # @return (see #get_all_timetables)
  def Scraper.get_all_programs(url)
    begin
      page = Nokogiri::HTML(open(url))

      base_url = /(.+\/)/.match(url)[1]
      copy_li = page.css('div#copy li')
      child_links = copy_li.collect { |a| a.child }
     
      # get program code, name, id and link
      program_info = []
      child_links.each do |link|
        program_hash = { "code" => link['href'].upcase[0,4], 
                         "name" => link.text }
        program = DBHandler.create_department(program_hash)
        program_hash["id"] = program["id"]
        program_hash["link"] = base_url + link['href']
        program_info << program_hash
      end 

    rescue
      self.log("get_all_programs failed.")
      nil
    end
  end
end
