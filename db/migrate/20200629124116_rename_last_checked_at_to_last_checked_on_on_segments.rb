class RenameLastCheckedAtToLastCheckedOnOnSegments < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :segments, :last_checked_at, :last_checked_on
  end

  def self.down
    rename_column :segments, :last_checked_on, :last_checked_at
  end
end
