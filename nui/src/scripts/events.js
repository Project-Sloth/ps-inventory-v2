const InventoryEvents = {
	/**
	 * =============================================
	 * INVENTORY EVENTS
	 * =============================================
	 */

	/**
	 * Event to pass important configuration
	 * variables to the NUI,
	 * @param {object} data
	 */
	init: (data) => {
		console.log(JSON.stringify(data));

		// Set debugging
		if (typeof data.debugging !== 'undefined') {
			Debugger.enabled = data.debugging;
		}

		// Build themes
		if (data.themes) {
			Inventory.Settings.BuildThemes(data.themes);
		}

		// Set player information
		if (data.player) {
			Debugger.log(JSON.stringify(data.player));
			Inventory.UpdatePlayerInformation(data.player);
		}

		// Set inventory configuration
		if (data.inventory) {
			Inventory.State.Configuration = {
				...Inventory.State.Configuration,
				...data.inventory,
			};
		}

		// Set language
		if (data.locales) {
			Language.SetLocales(data.locales);
			Inventory.Events.OnLanguageSet();
		}

		// Show inventory is ready for use
		InventoryNotify.Events.Process({
			process: 'notification',
			icon: 'fas fa-check-circle',
			color: '#beda17',
			message:
				Language.Locale('inventoryReady') ||
				'Inventory is ready for use',
		});
	},

	/**
	 * Updates various inventory data
	 * @param {object} data
	 */
	update: (data) => {
		if (typeof data.external == 'object') {
			if (data.external.id && data.external.type) {
				Nui.request('updateExternalState', {
					external: {
						type: data.external.type,
						id: data.external.id,
					},
				});
			}
		}

		Inventory.Events.UpdateInventory(data);
	},

	/**
	 * Toggles hotbar
	 */
	toggleHotbar: () => {
		Inventory.Settings.ToggleHotbar();
	},

	/**
	 * Updates player inventory data
	 * @param {object} data
	 */
	updatePlayerData: (data) => {
		Inventory.UpdatePlayerInformation(data);
	},

	/**
	 * Adds a crafting queue item
	 * @param {object} data
	 */
	addCraftingQueueItem: (data) => {
		Inventory.Utilities.AddCraftingQueueItem(data);
	},

	/**
	 * Removes a crafting queue item after completion or cancelation
	 * @param {object} data
	 */
	removeCraftingQueueItem: (data) => {
		Inventory.Utilities.RemoveCraftingQueueItem(data.id);
	},

	/**
	 * Starts a crafting queue timer
	 * @param {object} data
	 */
	startCraftingQueueTimer: (data) => {
		Inventory.Utilities.StartCraftingQueueTimer(data.id);
	},

	/**
	 * Updates health status
	 * @param {object} data
	 */
	health: (data) => {
		Inventory.Events.OnHealthUpdate(data);
	},

	/**
	 * Event for opening the NUI
	 * @param {object} data
	 */
	open: (data) => {
		Inventory.Events.Open(data);
	},

	/**
	 * Event for closing the NUI
	 * @param {object} data
	 */
	close: (data) => {
		Inventory.Events.Close(data);
	},

	/**
	 * =============================================
	 * INVENTORY NOTIFY EVENTS
	 * =============================================
	 */

	notify: (data) => {
		InventoryNotify.Events.Process(data);
	},

	/**
	 * =============================================
	 * INTERACTION EVENT
	 * =============================================
	 */

	interact: (data) => {
		switch (data.process) {
			case 'show':
				Interact.Events.Show(data);
				break;

			case 'hide':
				Interact.Events.Hide();
				break;
		}
	},
};
