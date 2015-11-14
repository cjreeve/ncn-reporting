class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue

  def formatted_content
    ActionController::Base.helpers.strip_tags(
      self.content).gsub(/(?:\n\r?|\r\n?)/, '<br>').split('<br><br>').reject(&:empty?).join('<br><br>').html_safe
  end
end
