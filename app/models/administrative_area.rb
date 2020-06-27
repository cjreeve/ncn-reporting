class AdministrativeArea < ApplicationRecord

  attr_accessor :issue_id

  has_many :issues
  belongs_to :group

  has_many :user_admin_area_selections
  has_many :users, through: :user_admin_area_selections
  has_many :segements, dependent: :destroy

  before_validation :set_blank_short_name
  before_validation :set_http

  def set_blank_short_name
    self.short_name = self.name unless self[:short_name].present?
  end

  def short_name
    self[:short_name].blank? ? self.name : self[:short_name]
  end


  def set_http
    # ensure the url includes http or https
    if self.reporting_url.present?
      self.reporting_url.strip!
      unless self.reporting_url[0..6] == 'http://' || self.reporting_url[0..7] == 'https://'
        self.reporting_url = 'http://' + self.reporting_url
      end
    end
  end

end
