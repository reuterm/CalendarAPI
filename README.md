# CalendarAPI
Calendar Rest API with multiple frontends

## Installing Components
### Node Js
Node and its package manger npm can be installed by using the built in linux
commands:
```shell
sudo apt-get update
sudo apt-get install npm
The “npm” package should include Node Js, if not run:
sudo apt-get install nodejs
```
### Mongo DB
The easiest way to install Mongo DB is by integrating it into the package management
system:
```shell
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv
7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/
3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodborg-
3.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
```
Afterwards Mongo must be configured before it can be used:
```shell
sudo mkdir -p /data/db
sudo chown <username> /data/db
```
### Bower
Bower is a package manager for web front-end packages. It can be installed with npm.
The “nodes-legacy" package creates a symbolic link for bower.
sudo npm install -g bower
sudo apt-get install nodejs-legacy
## Running it
### Mongo DB
In case there is not enough space on the virtual machine, Mongo must be run with the
“small-files” flag set:
```shell
mongod [--smallfiles] [--logpath mongo.log]
```
### Server
The code does not include any Node modules, therefore dependencies have to be
installed first:
(inside source folder)
```shell
npm install
cd ./public
bower install
cd ../
nodes server.js
```
The server is now running and will listen to port 8080.
## Usage
### API
GET:
```
/api/events ➔ display all events
/api/events/:id ➔ display particular event
/api/events/tag/:tag ➔ display all events with a particular tag
/api/events/date/:data ➔ display all events on certain date
/api/events/query/:query ➔ display all events with “:query” their name, description or
venue
/api/import ➔ import dummy data to get started with
/api/syncToGoogle ➔ insert all events stored in the database to Google Calendar
/api/syncFromGoogle ➔ insert all events from Google Calendar into database
```
POST:
```
/api/events ➔ add event
```
PUT:
```
/api/events/:id ➔ update particular event
```
DELETE:
```
/api/events/:id ➔ delete particular event
/api/events ➔ delete every event
```
### Web Application
The application is available at http://<ip-address>:8080/static/app.html
Events can be added from the “Add Event” form. Clicking on an event will load all its
information into the “Edit Event” form. From there it can be updated or deleted.
### Used Libraries
#### ui-calendar
A complete AngularJS directive for the Arshaw FullCalendar.
https://github.com/angular-ui/ui-calendar
#### FullCalendar
Full-sized drag & drop event calendar (jQuery plugin).
https://github.com/fullcalendar/fullcalendar
