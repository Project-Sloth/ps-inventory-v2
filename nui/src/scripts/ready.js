window.Interact = Interact;

/**
 * Main initializations happen here
 */
$(document).ready(function () {
	/**
	 * Event onMessage processor
	 */
	window.addEventListener('message', function (event) {
		Nui.processEvent(event.data.action, event.data);
	});

	Inventory.Settings.RegisterColorPickerHandler();

	/**
	 * Handles escape key event to close
	 */
	$(window).on('keydown', function (e) {
		switch (e.keyCode) {
			case 27:
				Nui.request('close');
				break;

			case 9:
				Nui.request('close');
				break;
		}
	});

	$(document).on('keyup keydown', function (e) {
		Inventory.State.Keys.Ctrl = e.ctrlKey;
	});
});
