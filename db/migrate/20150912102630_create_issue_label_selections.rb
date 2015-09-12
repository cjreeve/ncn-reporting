class CreateIssueLabelSelections < ActiveRecord::Migration
  def change
    create_table :issue_label_selections do |t|
      t.references :issue, index: true
      t.references :label, index: true

      t.timestamps
    end
  end
end
