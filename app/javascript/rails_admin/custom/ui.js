//= require_tree .

import * as toastr from "toastr";
window.toastr = toastr;

document.addEventListener("rails_admin.dom_ready", function() {
	$('[rel="tooltip"]').tooltip();
	$('#update_if_exists').removeClass('form-control');

	$(".diplayModalBtn").on('click', function() {
		var idModal = $(this).attr('idmodal');
		$(`#${idModal}`).modal();

	});
});