# NCN Reporting

This code is for the ncn-reporting tool that is used by Sustrans volunteers to report probably on the NCN and collaborate with other volunteers in resolving them.

Getting started instructions for using the site are provided here:
https://ncn-reporting-staging.herokuapp.com/welcome

The site requires rails 5.2.2 and ruby 2.4.1

Create a database:
    sudo -u postgres psql
    create database ncn_reporting_development

import database:
    pg_restore --verbose --clean --no-acl --no-owner -h localhost -U msdev -W -d ncn_reporting_development ncn_reporting_development.dump


Rename config/database.yml.example to config/database.yml

Check migrations run:
    rake db:migrate

Run rails server:
    rails s

Run the console and reset the first user's account password (if not already asdasdasd)
    rails c
    u = User.first
    u.password = 'asdasdasd'
    u.save


Deploy:
git push staging dev-2019-07-27-rails-5:master
