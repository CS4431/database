require 'nokogiri'
require 'open-uri'
require 'logger.rb'

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
      child_links_href = child_links.collect { |a| a['href'] }

      # append the root URL to the relative HTML files
      child_links_href.map { |a| base_url + a }
    rescue
      self.log("get_all_programs failed.")
      nil
    end
  end
end