const Nui = {
	/**
	 * Makes a request to an NUI callback in LUA
	 * @param {string} path
	 * @param {object} data
	 * @returns promise
	 */
	request: (path, data = {}) => {
		return $.ajax({
			url: `https://${GetParentResourceName()}/${path}`,
			type: 'POST',
			dataType: 'json',
			data: JSON.stringify(data),
		});
	},

	/**
	 * Processes an NUI event sent from LUA
	 * @param {string} eventName
	 * @param {object} eventData
	 */
	processEvent: (eventName, eventData) => {
		if (!InventoryEvents[eventName]) {
			return false;
		}

		// Call the event
		InventoryEvents[eventName](eventData);

		// Update inventory when data.items comes through
		if (eventData.items && eventName !== 'open') {
			InventoryEvents.update(eventData);
		}
	},
};
