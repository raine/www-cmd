var coffee  = require("coffee-script");
var express = require('express');
var http    = require('http');
var path    = require('path');
var _       = require('underscore');
var spawn   = require('child_process').spawn;
var cliff   = require('cliff');
var config  = require('./config');
var app = express();

app.configure(function() {
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

console.log('Initialized with commands:');
console.log(cliff.stringifyObjectRows(
	commands.map(function(obj) {
		obj = _.clone(obj);
		if (_.isFunction(obj.command))
			obj.command = '[Function]';
		return obj;
	}),
	['text', 'command', 'id'],
	['red', 'blue', 'green']
));

app.post('/execute/:id', function(req, res) {
	var cmdId = +req.params.id;
	var cmd   = _.findWhere(commands, { id: cmdId });

	if (!cmd) {
		console.log('Command not found');
		return res.send(404);
	}

	var command;
	if (_.isFunction(cmd.command)) {
		command = cmd.command(req);
	} else {
		command = cmd.command;
	}

	console.log('Running command `' + command + '`');
	var resp = "$ " + command + "\n";

	var exec = require('child_process').exec;
	exec(command, function(err, stdout) {
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
