class ChangeLastCheckedAtFromTimeToDateOnSegments < ActiveRecord::Migration[5.2]
  def up
    change_column :segments, :last_checked_at, :date
  end

  def down
    change_column :segments, :last_checked_at, :datetime
  end
end
