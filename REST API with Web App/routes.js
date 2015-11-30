module.exports = function(app) {
	var events = require('./controllers/events');
	app.use(function(req, res, next) {
	  res.header("Access-Control-Allow-Origin", "*");
	  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
	  res.header('Access-Control-Allow-Methods', 'POST, GET, PUT, DELETE, OPTIONS');
	  next();
	});
	app.get('/api/events', events.findAll);
	app.get('/api/events/:id', events.findById);
	app.get('/api/events/tag/:tag', events.findByTag);
	app.get('/api/events/date/:date', events.findByDate);
	app.get('/api/events/query/:query', events.findByQuery);
	app.post('/api/events', events.addEvent);
	app.put('/api/events/:id', events.updateEvent);
	app.delete('/api/events/:id', events.deleteEvent);
	app.delete('/api/events', events.deleteAll);
	app.get('/api/syncToGoogle', events.syncToGoogle);
	app.get('/api/syncFromGoogle', events.syncFromGoogle);
	app.get('/api/import', events.import)
}