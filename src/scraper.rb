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
      year = page.css("b").text[2,2]

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

      program_info.each do |program|
        Scraper.get_all_courses(program["link"], program["id"], year)
      end

    rescue
      self.log("get_all_programs failed.")
      nil
    end
  end

  # Parses all courses in a program
  # @param url [String] url of page to parse
  # @param program_id [int] department id for the course page
  # @param term [String] the term this course is in
  def Scraper.get_all_courses(url, program_id, term)
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
          course_hash["title"] = line.text.gsub("\n", "")
          looking_for += 1
        when 2
          # look for instructor
          if /Instructor: [.]*/.match(line.text)
            #puts line.text
            course_hash["instructor"] = line.text.gsub("Instructor: ", "")
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

      # add courses to database and get course books
      courses.each do |course|
        data = {"title" => course["title"],
                "code" => course["code"][0,9],
                "section" => course["code"][10,2],
                "department_id" => program_id,
                "instructor" => course["instructor"],
                "term" => term + course["code"][10] }
        db_data = DBHandler.create_course(data)
        Scraper.get_all_books(course["books_link"], db_data["id"]) 
      end

    rescue
      self.log("get_all_courses failed.")
      nil
    end
  end

  # Parses all books in a course
  # @param url [String] url of page to parse
  # @param course_id [int] id of the course the book page belongs to
  def Scraper.get_all_books(url, course_id)
    begin
      page = Nokogiri::HTML(open(url))
      book_titles = []
      page.css('em').each { |title| book_titles << title.text }
      text = page.to_s

      img_url_base = "http://lakehead.bookware3000.ca/eSolution_config/partimg/large/"

      book_groups = text.split("ISBN: ")

      editions = []
      book_titles.each_index do |title_index|
        edition_hash = Hash.new
        title = book_titles[title_index]

        # remove all text before book title
        split_text = book_groups[title_index + 1]
        lines = split_text.split(/<br>|\n/)

        # isbn is the first line
        isbn = lines[0]
        edition_hash["isbn"] = isbn
        edition_hash["title"] = title
        edition_hash["image"] = img_url_base + isbn + ".jpg"

        lines.each do |line|
          if /Author: [.]*/.match(line)
            author = line.gsub("Author: ", "")
            author = author.gsub("&nbsp;", "").strip
            edition_hash["author"] = author
          elsif /Publisher: [.]*/.match(line)
            publisher = line.gsub("Publisher: ", "")
            publisher = publisher.gsub("&nbsp;", "").strip
            edition_hash["publisher"] = publisher
          elsif /Edition: [.]*/.match(line)
            edition = line.gsub("Edition: ", "")
            edition = edition.gsub("&nbsp;", "").strip
            edition_hash["edition"] = edition
          elsif /Cover: [.]*/.match(line)
            cover = line.gsub("Cover: ", "")
            cover = cover.gsub("&nbsp;", "").strip
            edition_hash["cover"] = cover
          end
        end
        # add edition to list
        editions << edition_hash
      end

      # add books to database
      editions.each do |edition|
        db_edition = DBHandler.create_book(edition)
        DBHandler.create_course_book({"course_id" => course_id,
                                     "edition_id" => db_edition["id"]})
      end
    rescue
      self.log("get_all_books failed.")
      nil 
    end
  end

end
