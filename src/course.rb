class Course < ActiveRecord::Base
  self.table_name = "course"

  # Returns Course data as a hash
  def to_hash
  hash = {
    "id" => id,
    "title" => title,
    "code" => code,
    "section" => section,
    "department_id" => department_id,
    "instructor" => instructor,
    "term" => term }
  end
end
