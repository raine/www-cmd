$(function() {
	$('button').click(function() {
		var cmdId = $(this).attr('data-command-id');
		$.post('/execute/' + cmdId, function(data) {
			console.log(data);
		})
	});
});
