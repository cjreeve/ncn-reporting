# NCN Reporting

This Ruby on Rails app is for the ncn-reporting tool that is used by (some) Sustrans volunteers to report problems on the Nation Cycle Network and collaborate with other volunteers in resolving them. It was created by Christopher Reeve with input from other Sustrans volunteers. It replaced awkward spreadsheets with the ability to report an issue with a smart phone when out on a ride along an NCN route. Rangers for the particular route segment would be notified of the issue as well as members of Sustrans staff if the type of problem is assigned an urgent priority. Issues can be in the states of *draft*, *submitted*, *published* (accepted by a ranger), *started* and *closed*. A map shows markers were the issues are located as well as when a route was last checked by a ranger.

With the help of more volunteer developers we could potentially open this reporting tool up to the public to alert Sustrans rangers of problems along the NCN.

## Submitting improvements

Please clone the repository, create a branch and create a pull request from your branch to the main branch of this repository.

## Development notes

The site requires rails 5.2.2 and ruby 2.6.5

Create a database:
    sudo -u postgres psql
    create database ncn_reporting_development

import database:
    pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -W -d ncn_reporting_development ncn_reporting_development.dump


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


Deploy branch to staging:
git push staging dev-branch:master


Copy production image bucket to staging:
aws s3 sync s3://ncn-reporting s3://ncn-reporting-staging

## Licence

Released into the wild under the Apache License Version 2.0
The hope is that anyone with a little time might help make it better
