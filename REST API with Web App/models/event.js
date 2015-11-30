var mongoose = require('mongoose'),
Schema = mongoose.Schema;

var EventSchema = new Schema({
	title: String,
	description: String,
	tags: [String],
	start: Date,
	end: Date,
	venue: String
});

mongoose.model('Event', EventSchema);