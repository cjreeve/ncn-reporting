class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :issue
  has_one :image, dependent: :destroy

  # accepts_nested_attributes_for :image
  accepts_nested_attributes_for(
    :image,
    allow_destroy: true,
    reject_if:  proc { |a| a[:src].blank? }
  )

  validates :content, presence: { message: 'Please provide a comment'}

  def formatted_content
    ApplicationController.helpers.render_markdown(
      ActionController::Base.helpers.strip_tags(
        self.content).gsub(/(?:\n\r?|\r\n?)/, '<br>').split('<br><br>').reject(&:empty?).join('<br><br>'
      ),
      'restricted'
    )
  end
end
