class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue

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
