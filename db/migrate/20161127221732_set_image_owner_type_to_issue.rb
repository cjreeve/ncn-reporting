class SetImageOwnerTypeToIssue < ActiveRecord::Migration
  def change
    ActiveRecord::Base.record_timestamps = false
    begin
      Image.all.each do |image|
        image.update_attributes(owner_type: 'Issue')
      end
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end
end
