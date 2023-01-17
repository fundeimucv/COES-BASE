function replaceClassLabel(ele) {
  ele.replace('label', 'badge');
  ele.replace('label-danger', 'bg-danger');
  ele.replace('label-default', 'bg-secondary');
};

$(document).ready(function() {
	document.querySelectorAll('.label').forEach(x => replaceClassLabel(x.classList));
	$('[rel="tooltip"]').tooltip();
	$('.tooltip-btn').tooltip();
	$('.popover').popover();
});
