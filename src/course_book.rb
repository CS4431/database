class CourseBook < ActiveRecord::Base
  self.table_name = "course_book"

  # Returns CourseBook data as a hash
  def to_hash
    hash = {
      "course_id" => course_id,
      "edition_id" => edition_id }
  end
end
