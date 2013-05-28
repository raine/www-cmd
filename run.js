var express = require('express');
var http    = require('http');
var path    = require('path');
var config  = require('./config');
var _       = require('underscore');
var spawn   = require('child_process').spawn;

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 8080);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.logger('dev'));
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.get('/', function(req, res) {
	res.render('index', { commands: commands });
});

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});

var commands = config.buttons.map(function(obj, i) {
	obj.id = i;
	return obj;
});

app.post('/execute/:id', function(req, res) {
	var cmdId = +req.params.id;
	var cmd   = _.findWhere(commands, { id: cmdId });

	if (!cmd) {
		console.log('Command not found');
		return res.send(404);
	}

	console.log('Running command `' + cmd.command + '`');

	var resp = "$ " + cmd.command + "\n";

	var exec = require('child_process').exec;
	exec(cmd.command, function(err, stdout) {
		if (err) {
			resp += err.toString();
			console.log(err.toString());
		} else {
			resp += stdout;
			console.log(stdout);
		}

		res.send(resp);
	});
});
