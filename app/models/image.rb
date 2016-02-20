class Image < ActiveRecord::Base
  belongs_to :issue

  mount_uploader :src, ImageUploader

  before_validation :fetch_remote_image

  def fetch_remote_image
    self.remote_src_url = self.url if self.url.present? && self.src.blank?
  end
end
