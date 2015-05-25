Users:  first_name, last_name, email, volunter_number, date_joined, active, has:roll

Issue:  title, description, importance, time_reported, time_completed
        has:state, has:comments, has:reporter, has:assignee, has:images, has:location
        has:route, has:region

Comment: belogs_to:issue:user:route:region
Image: src, title(o), description(o)
State: draft, submitted, acknowledged, in-progress, resolved, re-opened, archived, deleted
Location: name, coord, url
Route: Name, url to gpx track, has:comments
Region: Name, comments
Roll: name


FEATURES
* Issue has many followers and User has many interests
* Updates on issues are posted to users home page
* User can express interest in region of route
* Emails sent to users when activity within interest occurs

VIEWS
* Home page shows newsfeed and stats
* Users: index, show, edit
* Issues: index (filters), show, edit, new
* Regions: index, edit, new, show (lists routes and most recent issues)
* Routes: index, edit, new, show


(o) = optional
