require 'net/http'
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
          # remove "Computer Requirements" from the title
          course_hash["title"] = line.text.gsub("\n", "").gsub("Computer Requirements", "")
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
                "term" => term.to_s + course["code"][10] }
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
        edition_hash["isbn"] = Scraper.convert_to_isbn_13(isbn)
        edition_hash["title"] = title
        img_url = img_url_base + isbn + ".jpg"
        edition_hash["image"] = (Scraper.verify_link(img_url)) ? img_url : nil

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

  # Downloads all book images and stores them in public/images/books
  def Scraper.download_book_images
    #get all books
    books = DBHandler.get_books({}, 10000, 0)

    public_folder = "../public/"
    save_location = "images/books/"
    not_found_link = save_location + "notfound.jpg"

    books.each do |book|
      image_uri = book["image"]
      if image_uri.start_with?("http")
        begin
          image = open(image_uri).read
          uri_parts = image_uri.split("/")
          image_name = uri_parts.last
          File.open(public_folder + save_location + image_name, 'wb') do |fo|
            fo.write image
          end
          new_uri = save_location + image_name
          DBHandler.update_edition_attribute(book["id"], "image", new_uri)
        rescue
          DBHandler.update_edition_attribute(book["id"], "image", nil)
        end
      end
    end
  end

  # Verify that the destination of a link exists
  # @param url [String] url of the link to verify
  # @return [Bool] true if the link exists; false otherwise
  def Scraper.verify_link(url)
    uri = URI(url)
    request = Net::HTTP.new uri.host
    response = request.request_head uri.path
    return response.code.to_i == 200
  end

  # Converts an isbn into isbn-13 format
  # @param isbn [String] the isbn to convert
  # @return [String] the isbn in isbn-13 format; nil if input is not a valid isbn
  def Scraper.convert_to_isbn_13(isbn)
    return isbn if (isbn.size == 13)
    return nil unless (isbn.size == 10)
    
    # remove checksum
    isbn = isbn[0,9]

    isbn = "978" + isbn
    mult_values = [1,3]
    index = 0
    checksum = 0
    isbn.each_char do |c|
      mult_by = mult_values[index % 2]
      checksum += c.to_i * mult_by
      index += 1
    end
    isbn += (10 - (checksum % 10)).to_s
    isbn
  end

end
