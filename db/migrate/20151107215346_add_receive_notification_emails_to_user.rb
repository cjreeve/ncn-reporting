class AddReceiveNotificationEmailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :receive_email_notifications, :boolean, null: false, default: true
  end
end
