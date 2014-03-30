# Handels course_book database table
class CourseBook < ActiveRecord::Base
  self.table_name = "course_book"
  validates :course_id, presence: true
  validates :edition_id, presence: true

  # Returns CourseBook data as a hash
  def to_hash
    hash = {
      "course_id" => course_id,
      "edition_id" => edition_id }
  end
end
