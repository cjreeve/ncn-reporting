class Image < ActiveRecord::Base

  attr_accessor :rotate

  belongs_to :issue

  mount_uploader :src, ImageUploader

  ANGLES = [90, 180, -90]
  before_validation :fetch_remote_image

  after_save :rotate_image!, if: ->(obj){ obj.rotation.present? && !obj.rotation.zero? }

  def fetch_remote_image
    self.remote_src_url = self.url if self.url.present? && self.src.blank?
  end

  def rotate_image!
    self.src.recreate_versions!
    self.update_attributes(rotation: nil) unless self.rotation.nil?
  end

  def text_to_rotation(text)
    if text == 'left'
      self.rotation = -90
    elsif text = 'right'
      self.rotation = 90
    end
  end

end
