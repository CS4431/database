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

  # Parses all courses in a program
  #
  # @param (see #get_all_timetables)
  def Scraper.get_all_courses(url)
    begin
      page = Nokogiri::HTML(open(url))
      td = page.css('td')
      td = td.select { |x| x.text != "" }

      courses = []
      course_hash = Hash.new
      looking_for = 0
      td.each do |line|
        case looking_for
        when 0
          # look for course code
          if /[A-Z]{4}-[0-9]{4}-[A-Z]{2}/.match(line.text)
            #puts line.text
            course_hash["code"] = line.text
            looking_for += 1
          end
        when 1
          # course name is the line after course code, no need to search
          #puts line.text
          course_hash["title"] = line.text
          looking_for += 1
        when 2
          # look for instructor
          if /Instructor: [.]*/.match(line.text)
            #puts line.text
            course_hash["instructor"] = line.text
            looking_for += 1
          end
        when 3
          # look for books link
          if /BOOKS[.]*/.match(line.text)
            link = line.child['href']
            # remove \n from links
            link.gsub!("\n", "")
            puts link
            course_hash["books_link"] = link
            courses << course_hash
            course_hash = Hash.new
            looking_for = 0
          end
        end 
      end
    rescue
      self.log("get_all_courses failed.")
      nil
    end
  end

  # Parses all books in a course
  #
  # @param (see #get_all_timetables)
  def Scraper.get_all_books(url)
    page = Nokogiri::HTML(open(url))
    book_titles = page.css('em')
    text = page.to_s

    img_url_base = "http://lakehead.bookware3000.ca/eSolution_config/partimg/large/"

    editions = []
    edition_hash = Hash.new
    book_titles.each do |title|
      # remove all text before book title
      text = text.split(title)[1]
      lines = text.split(/<br>|\n/)
      looking_for = :isbn
      lines.each do |line|

        case looking_for
        when :isbn
          # look for isbn
          if /ISBN: [0-9]*/.match(line)
            edition_hash["title"] = title.text
            isbn = line.gsub("ISBN: ", "")
            isbn = isbn.gsub("&nbsp;", "").strip
            edition_hash["isbn"] = isbn
            edition_hash["image"] = img_url_base + isbn + ".jpg"
            looking_for = :author
          end
        when :author
          # look for author
          if /Author: [.]*/.match(line)
            author = line.gsub("Author: ", "")
            author = author.gsub("&nbsp;", "").strip
            edition_hash["author"] = author
            looking_for = :publisher
          end
        when :publisher
          # look for publisher
          if /Publisher: [.]*/.match(line)
            publisher = line.gsub("Publisher: ", "")
            publisher = publisher.gsub("&nbsp;", "").strip
            edition_hash["publisher"] = publisher
            looking_for = :edition
          end
        when :edition
          # look for edition
          if /Edition: [.]*/.match(line)
            edition = line.gsub("Edition: ", "")
            edition = edition.gsub("&nbsp;", "").strip
            edition_hash["edition"] = edition
            looking_for = :cover
          end
        when :cover
          # look for cover
          if /Cover: [.]*/.match(line)
            cover = line.gsub("Cover: ", "")
            cover = cover.gsub("&nbsp;", "").strip
            edition_hash["cover"] = cover

            editions << edition_hash
            edition_hash = Hash.new
            break
          end
        end
      end
    end
  end

end
