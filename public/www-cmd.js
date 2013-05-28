$(function() {
	var $stdout = $('.stdout');

	var showOutput = function(stdout) {
		$stdout.show();
		$stdout.find('pre').text(stdout);
	};

	$('button').click(function() {
		var cmdId = $(this).attr('data-command-id');
		$.post('/execute/' + cmdId, function(data) {
			showOutput(data);
			console.log(data);
		});
	});
});
