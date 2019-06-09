class AddCommentReferenceToImages < ActiveRecord::Migration
  def change
    add_reference :images, :comment, index: true, foreign_key: true
  end
end
