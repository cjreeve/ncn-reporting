# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# [["NCN1", "NCN 1"], ["NCN4", "NCN 4"], ["NCN13", "NCN 13"], ["NCN20", "NCN 20"], ["NCN21", "NCN 21"]].each do |route_names|
#   route = Route.find_by(name: route_names[0])
#   if route
#     route.name = route_names[1]
#     route.save
#   end
# end



# ActiveRecord::Base.record_timestamps = false
begin
  User.all.each do |user|
    puts "updating user #{ user.id }  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    user.administrative_area_ids = user.areas.collect{ |a| a.administrative_area_ids }.flatten.compact
    user.save
  end
ensure
  ActiveRecord::Base.record_timestamps = true
end

# ActiveRecord::Base.record_timestamps = false
# begin
#   creator = User.first

#   User.all.each do |user|
#     user.creator = creator
#     user.save
#   end
# ensure
#   ActiveRecord::Base.record_timestamps = true
# end




# ActiveRecord::Base.record_timestamps = false
# begin
#   Issue.where(state: 'resolved').each do |i|
#     i.resolution = "resolved"
#     i.state = "closed"
#     i.save
#   end
#   Issue.where(resolution: [nil, ""], state: ["unsolvable", "resolved", "closed"]).each do |i|
#     i.resolution = "resolved"
#     i.state = "closed"
#     i.save
#   end
# ensure
#   ActiveRecord::Base.record_timestamps = true
# end



# user_updated_ats = [
#   [26,'2015-09-29 08:44:27 +0100'],
#   [6,'2015-10-28 16:33:32 +0000'],
#   [15,'2015-09-15 17:35:14 +0100'],
#   [16,'2015-09-26 13:01:08 +0100'],
#   [8,'2015-08-28 07:16:45 +0100'],
#   [23,'2015-09-26 15:30:24 +0100'],
#   [12,'2015-09-11 16:59:32 +0100'],
#   [17,'2015-09-28 19:19:56 +0100'],
#   [18,'2015-09-26 13:04:20 +0100'],
#   [20,'2015-09-26 18:24:44 +0100'],
#   [33,'2015-11-02 16:03:39 +0000'],
#   [28,'2015-10-16 18:28:29 +0100'],
#   [19,'2015-10-22 15:11:45 +0100'],
#   [22,'2015-10-15 09:46:11 +0100'],
#   [30,'2015-10-17 13:27:20 +0100'],
#   [31,'2015-10-17 17:22:05 +0100'],
#   [2,'2015-10-25 22:05:52 +0000'],
#   [29,'2015-11-04 09:11:38 +0000'],
#   [32,'2015-10-26 16:55:31 +0000'],
#   [9,'2015-10-30 10:26:58 +0000'],
#   [27,'2015-11-08 18:42:32 +0000'],
#   [34,'2015-11-05 17:04:45 +0000'],
#   [10,'2015-11-08 19:00:16 +0000'],
#   [7,'2015-11-07 13:00:40 +0000'],
#   [25,'2015-11-09 09:19:06 +0000'],
#   [13,'2015-11-12 16:04:18 +0000'],
#   [21,'2015-11-12 16:04:56 +0000'],
#   [4,'2015-11-13 17:28:40 +0000'],
#   [24,'2015-11-12 16:02:55 +0000'],
#   [11,'2015-11-14 16:01:39 +0000'],
#   [1,'2015-11-15 00:45:30 +0000'],
#   [3,'2015-11-15 00:45:10 +0000'],
#   [14,'2015-09-16 14:45:01 +0100']
# ]

# ActiveRecord::Base.record_timestamps = false
# begin
#   user_updated_ats.each do |user_details|
#     u = User.find(user_details[0])
#     u.updated_at = user_details[1]
#     u.save
#   end
# ensure
#   ActiveRecord::Base.record_timestamps = true
# end


# region = Region.find_or_create_by(name: 'London')
# region_atributes = {
#   lat: 51.517106,
#   lng: -0.113615,
#   map_zoom: 11,
#   email: 'noreply@ncn-reporting.herokuapp.com',
#   email_name: 'ncn-reporting',
#   notifications_sent_at: "2015-08-07 16:00"
# }
# region.update_attributes!(region_atributes)

# ActiveRecord::Base.record_timestamps = false
# begin
#   User.all.each do |user|
#     user.region = region
#     user.save
#   end
# ensure
#   ActiveRecord::Base.record_timestamps = true
# end


# # remove label options for staff that are not managing any routes
# ActiveRecord::Base.record_timestamps = false
# begin
#   label_sustrans = Label.find_by_name('sustrans')
#   label_council = Label.find_by_name('council')
#   User.includes(:areas, :routes).where(role: 'staff', is_admin: false, routes: {id: nil}, areas: {id: nil}).each do |user|
#     user.labels = []
#     user.save
#   end
# ensure
#   ActiveRecord::Base.record_timestamps = true
# end



# Set all staff accounts to show sustrans and
# ActiveRecord::Base.record_timestamps = false
# begin
#   label_sustrans = Label.find_by_name('sustrans')
#   label_council = Label.find_by_name('council')
#   User.where(role: 'staff').each do |user|
#     user.labels << label_sustrans
#     user.labels << label_council
#     user.save
#   end
# ensure
#   ActiveRecord::Base.record_timestamps = true
# end





# ["NCN 1", "NCN 4", "NCN 6", "NCN 12", "NCN 13", "NCN 20", "NCN 61", "NCN 125", "NCN 136", "NCN 208", "NCN 425"].each do |route_name|
#   Route.find_or_create_by(name: route_name)
# end

# %w{South-West South-East South-Central Central North North-East North-West}.each do |area_name|
#   Area.find_or_create_by(name: area_name)
# end

# [ ["Graffiti", 1], ["Turned", 2], ["Missing", 2], ["Wrong", 2], ["Obstruction", 2],["Obstruction!", 3],
#   ["Overgrown", 1], ["Uneven", 1], ["Pothole(s)", 2], ["Damaged", 1], ["Dangerous", 3]
# ].each do |problem_data|
#   Problem.find_or_create_by(name: problem_data[0], default_priority: problem_data[1])
# end

# %w{Signage Vegetation Surface Access Mile_Posts Portrait_Benches}.each do |category_name|
#   category = Category.find_or_create_by(name: category_name.gsub('_',' '))
# end


User.where(role: 'admin').each do |u|
  u.is_admin = true
  u.role = 'coordinator'
  u.save
end

User.where(role: 'locked').each do |u|
  u.is_locked = true
  u.role = 'volunteer'
  u.save
end



# Route.all.each do |route|
#   route.slug = route.name.parameterize
#   route.save
# end


# Issue.all.each do | issue |
#   Issue.record_timestamps = false
#   issue.save
#   Issue.record_timestamps = true
# end



# u = User.find_or_create_by(email: 'cjreeve@gmail.com')
# u.name = "Christopher Reeve"
# u.is_admin = true
# u.role = "volunteer"
# u.password = 'asdfasdf'
# u.save
# u = User.find_or_create_by(email: 'admin@sustrans.org.uk')
# u.name = "admin"
# u.role = "admin"
# u.password = 'password'
# u.save
# u = User.find_or_create_by(email: 'volunteer@sustrans.org.uk')
# u.name = 'volunteer'
# u.role = 'volunteer'
# u.password = 'password'
# u.save




# users = User.all

# Issue.all.each do |issue|
#   unless issue.user.present?
#     issue.user = users.shuffle.first
#     issue.save
#   end
# end


# area = Area.find_by_name('South-West')
# route = Route.find_by(name: "NCN 20")

# issue = Issue.find_or_create_by(title: "Sign turned", lat: "51.456840", lng: "-0.192560")
# issue.route = route
# issue.area = area
# issue.images << Image.new unless issue.images.present?
# issue.images[0].url = "https://lh3.googleusercontent.com/CBj_HjX3jAV6h2g8W7its3ioBdSXUdtwQ64naDDQXjc=w602-h802-no"
# issue.description = ""
# issue.priority = 2
# issue.reported_at = "28.05.2015"
# issue.state = "open"
# issue.save

# issue = Issue.find_or_create_by(title: "Graffiti on signs", lat: "51.438167", lng: "-0.189556")
# issue.route = route
# issue.area = area
# issue.images << Image.new unless issue.images.present?
# issue.images[0].url = "https://lh3.googleusercontent.com/W-I56RxNYyo2geeGYasQJ0yZ66vxE-moBagZof6PIr0=w602-h802-no"
# issue.description = ""
# issue.priority = 2
# issue.reported_at = "28.05.2015"
# issue.state = "open"
# issue.save
