class CreateUserLabelSelections < ActiveRecord::Migration
  def change
    create_table :user_label_selections do |t|
      t.references :user, index: true
      t.references :label, index: true

      t.timestamps
    end
  end
end
