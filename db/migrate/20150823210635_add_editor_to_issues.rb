class AddEditorToIssues < ActiveRecord::Migration
  def change
    add_reference :issues, :editor, index: true
  end
end
