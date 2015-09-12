class Label < ActiveRecord::Base
  has_many :issue_label_selections
  has_many :issues, through: :issue_label_selections

  validates :name, length: { in: 2..30, message: '- maximum label name length is 30 characters'}
end
