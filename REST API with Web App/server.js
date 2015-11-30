var express = require('express'),
mongoose = require('mongoose'),
bodyParser = require('body-parser')
fs = require('fs');

var mongoUri = 'mongodb://localhost/calendar';
mongoose.connect(mongoUri);
var db = mongoose.connection;
db.on('error', function () {
  throw new Error('unable to connect to database at ' + mongoUri);
});

var app = express();

// to run using Express 4 
// install bodyParser dependencies
//create an instance
var app = express();
//Express 4
// var env = process.env.NODE_ENV || 'development';

// if('development'== env){

    app.use(bodyParser.json());
	app.use(bodyParser.urlencoded({extended: true}));
	app.use('/static', express.static(__dirname + '/public'));
// };

// app.configure(function(){
//   app.use(express.bodyParser());
// });

require('./models/event');
require('./routes')(app);

// Google Calendar:
var clientID = "139393676124-6n6io89dqq37ros4c1jckai93k4l5a4l.apps.googleusercontent.com";
var clientSecret = "djvnX0Y43LLIkuqSJiINr-Fz";

app.listen(8080);
console.log('Listening on port 8080...');