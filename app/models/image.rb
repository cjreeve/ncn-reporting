class Image < ActiveRecord::Base
  belongs_to :issue

  mount_uploader :src, ImageUploader

  before_validation :fetch_remote_image

  # validates :file, presence: true

  def fetch_remote_image
    self.remote_src_url = self.url if self.url.present? && self.src.blank?

    # self.file = self.url
    # if self.url.present?
    #   if self.url.include?("http")
    #     self.remote_file_url = self.url
    #   else
    #     self.file = self.url
    #   end
    # end
  end

end
