# Handles edition database table
class Edition < ActiveRecord::Base
  self.table_name = "edition"
  belongs_to :edition_group, foreign_key: "edition_group_id"
  validates :isbn, presence: true
  validates :edition_group_id, presence: true

  # Converts the image uri into a full path uri if it refers to a local image
  def full_image_uri
    return nil if image.nil?
    return image if image.start_with?('http://')
    return 'http://bookmarket.webhop.org/' + image
  end

  # Returns Edition data as a hash
  def to_hash
    hash = {
      "id" => id,
      "isbn" => isbn,
      "edition_group_id" => edition_group_id,
      "author" => author,
      "edition" => edition,
      "publisher" => publisher,
      "cover" => cover,
      "image" => full_image_uri }
  end
end
