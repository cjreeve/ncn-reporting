class Label < ActiveRecord::Base
  has_many :issue_label_selections
  has_many :issues, through: :issue_label_selections

  validates :name, length: { in: 2..30, message: '- maximum label name length is 30 characters'}

  after_validation :downcase_name

  private

  def downcase_name
    self.name = self.name.downcase
  end
end