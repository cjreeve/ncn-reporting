class AddCommentReferenceToImages < ActiveRecord::Migration[4.2]
  def change
    add_reference :images, :comment, index: true, foreign_key: true
  end
end
