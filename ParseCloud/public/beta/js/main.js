$(document).ready(function(){

	$('#test').on('click touchstart', function(e){
		$('#form input[type=submit]').toggleClass('active');
		e.preventDefault();
	});

	$('#submit').on('click touchstart', function(e){
		$('#overlay').toggleClass('on');
		$('#box').toggleClass('on');
		e.preventDefault();
	});

	$('#overlay').on('click touchstart', function(e){
		$('#overlay').toggleClass('on');
		$('#box').toggleClass('on');
		e.preventDefault();
	});

});