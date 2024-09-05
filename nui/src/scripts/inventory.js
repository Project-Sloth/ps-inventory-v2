/**
 * Framework for Inventory
 */
const Inventory = {
	Themes: {},

	/**
	 * State keeper for inventory
	 */
	State: {
		Hotbar: false,

		Open: false,

		Items: [],
		ExternalItems: [],

		Configuration: {
			MaxInventoryWeight: 120000,
			MaxInventorySlots: 41,
			MaxExternalInventoryWeight: 800000,
			MaxExternalInventorySlots: 41,
		},

		Player: {
			name: 'Me',
			identifier: 'Not available',
		},

		Titles: {
			PlayerName: 'Me',
			MyInventory: 'Me',
			ExternalInventory: 'Drop',
		},

		DraggablesRegistered: false,

		BootstrapMenu: false,

		Keys: {
			Ctrl: false,
		},

		CraftingQueueTimer: {},
	},

	Health: {
		Selector: '.ui-character',

		High: {
			image: 'assets/ui/outlined-male.png',
		},

		Mid: {
			image: 'assets/ui/outlined-male-mid.png',
		},

		Low: {
			image: 'assets/ui/outlined-male-low.png',
		},
	},

	/**
	 * Selectors of the dom for inventory types
	 */
	Selectors: {
		Hot: '#hot-slots',
		BottomHot: '#bottom-hotbar-slots',
		Inventory: '#inventory-slots',
		External: '#external-slots',
		CraftingQueue: '#crafting-queue',
		BottomHotContainer: '#bottom-hotbar',
		ExternalInventory: '#external-inventory',

		Titles: {
			PlayerName: '.my-sub-title, .main-sub-title',
			MyInventory: '#my-inventory-title',
			ExternalInventory: '#external-inventory-title',
		},

		Weights: {
			InventoryWeight: '#my-inventory-weight',
			InventoryMaxWeight: '#my-inventory-max-weight',
			ExternalInventoryWeight: '#external-inventory-weight',
			ExternalInventoryMaxWeight: '#external-inventory-max-weight',
		},
	},

	/**
	 * Inventory events that are fired externally.
	 */
	Events: {
		MoveEvents: {
			HandleExternalToInventory: (data, payload, res) => {
				const isExternalToInventory =
					data.from === 'External' && data.to === 'Inventory';
				const isDropExternal =
					payload.external && payload.external.type === 'drop';
				const isInvalidExternal =
					!res.external ||
					!Array.isArray(res.external) ||
					res.external.length;

				if (
					!isExternalToInventory ||
					!isDropExternal ||
					isInvalidExternal
				) {
					return false;
				}

				Inventory.State.ExternalItems = [];
				$(Inventory.Selectors.ExternalInventory).hide();
				return true;
			},
		},

		/**
		 * When language is set, update dom
		 */
		OnLanguageSet: () => {
			$('#drop').html(Language.Locale('drop'));
			$('#use').html(Language.Locale('use'));
			$('#settings-modal-title').html(Language.Locale('settings'));
		},

		/**
		 * When item is dragged to use, or double clicked
		 * @param {int} slotId
		 * @param {string} inventoryType
		 * @param {object} item
		 */
		OnUse: async (slotId, inventoryType, item) => {
			if (typeof item.info !== 'undefined') {
				if (item.info.decayed) {
					return InventoryNotify.Events.Process({
						process: 'notification',
						icon: 'fas fa-times-circle',
						color: '#ff0000',
						message: Language.Locale('itemDecayed'),
					});
				}
			}

			const res = await Nui.request('useItem', {
				slotId: slotId,
				inventory: inventoryType,
				item: item,
			});
		},

		/**
		 * This event is fired when the inventory is opened
		 */
		OnOpen: () => {
			Inventory.Settings.DisableHotbar();

			$(Inventory.Selectors.Titles.PlayerName).html(
				Inventory.State.Player.name
			);
			$(Inventory.Selectors.Titles.MyInventory).html(
				Inventory.State.Player.name
			);
			Inventory.State.Open = true;

			if (window.Interact.State.Show) {
				window.Interact.Events.Hide(false);
			}
		},

		/**
		 * This event is fired when the inventory is closed
		 */
		OnClose: () => {
			Inventory.Settings.EnableHotbar();

			$(Inventory.Selectors.Titles.ExternalInventory).html(
				Inventory.State.Titles.ExternalInventory
			);

			Inventory.State.ExternalItems = [];
			$(Inventory.Selectors.ExternalInventory).hide();
			Inventory.State.Open = false;

			if (window.Interact.State.Show) {
				window.Interact.Events.Show();
			}
		},

		/**
		 * Updates health status for player
		 * @param {object} data
		 */
		OnHealthUpdate: (data) => {
			/**
			 * If currentHealth is provided
			 */
			if (typeof data.currentHealth !== 'undefined') {
				const el = $(Inventory.Health.Selector);
				const currentHealth = data.currentHealth - 100;

				/**
				 * Update image based on current health
				 */
				if (el.length) {
					if (currentHealth < 25) {
						el.attr('src', Inventory.Health.Low.image);
					} else if (currentHealth < 75) {
						el.attr('src', Inventory.Health.Mid.image);
					} else {
						el.attr('src', Inventory.Health.High.image);
					}
				}
			}
		},

		/**
		 * Updates inventory data / ui
		 * @param {object} data
		 */
		UpdateInventory: (data) => {
			if (typeof data.items !== 'undefined') {
				Inventory.State.Items = data.items;
				Inventory.RenderSlots('Hot', 5, data.items);
				Inventory.RenderSlots(
					'Inventory',
					Inventory.State.Configuration.MaxInventorySlots - 5,
					data.items
				);
				Inventory.UpdateInventoryWeights('Inventory');
			}

			if (typeof data.external !== 'undefined') {
				Inventory.Setup.ExternalInventory(data);
			}
		},

		/**
		 * Opens the inventory
		 * @param {object} data
		 */
		Open: (data) => {
			Inventory.Events.UpdateInventory(data);
			Inventory.Events.OnOpen();
			$('#inventory').fadeIn();
		},

		/**
		 * Closes the inventory
		 * @param {object} data
		 */
		Close: (data) => {
			if (Inventory.State.BootstrapMenu) {
				Inventory.State.BootstrapMenu.close();
			}

			$('#inventory').fadeOut(function () {
				Inventory.Events.OnClose();
			});
		},

		/**
		 * Removes attachment from weapon
		 * @param {int} slot
		 * @param {string} attachment
		 */
		RemoveAttachment: async (slot, attachment, component) => {
			let payload = {
				slot: slot,
				attachment: attachment,
				component: component,
			};

			/**
			 * Process the request
			 */
			try {
				// Disables draggables while request is being made
				Inventory.DisableDraggables();

				// Make request
				const res = await Nui.request('removeAttachment', payload);

				// Close the menu
				if (res.success) {
					if (Inventory.State.BootstrapMenu) {
						Inventory.State.BootstrapMenu.close();
					}
				}

				// Re-enables draggables
				Inventory.EnableDraggables();
			} catch (error) {
				// Re-enables draggables
				Inventory.EnableDraggables();
			}
		},

		/**
		 * Handles giving an item to closest player
		 * @param {object} data
		 */
		Split: async (data) => {
			let payload = data;

			/**
			 * Process the split
			 */
			try {
				// Disables draggables while request is being made
				Inventory.DisableDraggables();

				// Make request
				const res = await Nui.request('split', payload);

				// Re-enables draggables
				Inventory.EnableDraggables();
			} catch (error) {
				// Re-enables draggables
				Inventory.EnableDraggables();
			}
		},

		/**
		 * Handles giving an item to closest player
		 * @param {object} data
		 */
		Give: async (data) => {
			let payload = data;

			/**
			 * Process the giving of item
			 */
			try {
				// Disables draggables while request is being made
				Inventory.DisableDraggables();

				// Make request
				const res = await Nui.request('give', payload);

				/**
				 * If payload expected is not returned
				 */
				if (!res.success) {
					if (res.message) {
						InventoryNotify.Events.Process({
							process: 'notification',
							icon: 'fas fa-times-circle',
							color: '#ff0000',
							message: res.message,
						});
					}
				}

				// Re-enables draggables
				Inventory.EnableDraggables();
			} catch (error) {
				// Re-enables draggables
				Inventory.EnableDraggables();

				/**
				 * If the request fails
				 */
				return InventoryNotify.Events.Process({
					process: 'notification',
					icon: 'fas fa-times-circle',
					color: '#ff0000',
					message: Language.Locale('unableToComplete'),
				});
			}
		},

		/**
		 * Handles creation of a drop from item
		 * @param {object} data
		 */
		Drop: async (data) => {
			let payload = data;

			/**
			 * Process the dropping of item
			 */
			try {
				// Disables draggables while request is being made
				Inventory.DisableDraggables();

				// Make request
				const res = await Nui.request('drop', payload);

				if (
					typeof res.items !== 'undefined' ||
					typeof res.external !== 'undefined'
				) {
					Inventory.Events.UpdateInventory(res);
				}

				// Re-enables draggables
				Inventory.EnableDraggables();
			} catch (error) {
				// Re-enables draggables
				Inventory.EnableDraggables();

				/**
				 * If the request fails
				 */
				return InventoryNotify.Events.Process({
					process: 'notification',
					icon: 'fas fa-times-circle',
					color: '#ff0000',
					message: Language.Locale('unableToComplete'),
				});
			}
		},

		/**
		 * Handles re-ordering / stacking / transfers of items
		 * @param {object} data
		 */
		Move: async (data) => {
			let payload = {};

			// Set to inventory is origin is hot bar
			if (data.from == 'Hot') {
				data.from = 'Inventory';
			}
			if (data.to == 'Hot') {
				data.to = 'Inventory';
			}

			/**
			 * If they are moving from external to their inventory
			 */
			if (data.from == 'Inventory' && data.to == 'Inventory') {
				payload.action = 'swap';
				payload.target = data.to.toLowerCase();
				payload.items = [
					{
						slot: data.fromSlotId,
						newSlot: data.toSlotId,
						item: data.oldItem,
					},
					{
						slot: data.toSlotId,
						newSlot: data.fromSlotId,
						item: data.newItem,
					},
				];
			}

			/**
			 * If they are reording external inventory
			 */
			if (data.from == 'External' && data.to == 'External') {
				payload.action = 'swap';
				payload.target = data.to.toLowerCase();
				payload.items = [
					{
						slot: data.fromSlotId,
						newSlot: data.toSlotId,
						item: data.oldItem,
					},
					{
						slot: data.toSlotId,
						newSlot: data.fromSlotId,
						item: data.newItem,
					},
				];

				payload.external = {
					id: $(Inventory.Selectors.ExternalInventory).data('id'),
					name: $(Inventory.Selectors.ExternalInventory).data('name'),
					type: $(Inventory.Selectors.ExternalInventory).data('type'),
				};
			}

			/**
			 * If they are moving from external to their inventory
			 */
			if (data.from == 'External' && data.to == 'Inventory') {
				payload = {
					action: 'transfer',
					target: data.to.toLowerCase(),
					external: {
						id: $(Inventory.Selectors.ExternalInventory).data('id'),
						name: $(Inventory.Selectors.ExternalInventory).data(
							'name'
						),
						type: $(Inventory.Selectors.ExternalInventory).data(
							'type'
						),
					},
					item: data.oldItem,
					toSlotId: data.toSlotId,
					fromSlotId: data.fromSlotId,
				};
			}

			/**
			 * If they are moving from inventory to external
			 */
			if (data.from == 'Inventory' && data.to == 'External') {
				payload = {
					action: 'transfer',
					target: data.to.toLowerCase(),
					external: {
						id: $(Inventory.Selectors.ExternalInventory).data('id'),
						name: $(Inventory.Selectors.ExternalInventory).data(
							'name'
						),
						type: $(Inventory.Selectors.ExternalInventory).data(
							'type'
						),
					},
					item: data.oldItem,
					toSlotId: data.toSlotId,
					fromSlotId: data.fromSlotId,
				};
			}

			/**
			 * Process the moving
			 */
			try {
				// Disables draggables while request is being made
				Inventory.DisableDraggables();

				const res = await Nui.request('move', payload);

				// Re-enables draggables
				Inventory.EnableDraggables();

				// Make certain drops with last item taken are closed
				const closedExternal = Inventory.Events.MoveEvents.HandleExternalToInventory(
					data,
					payload,
					res
				);

				if (res.external && !closedExternal) {
					Inventory.Events.UpdateInventory({
						external: {
							items: res.external,
						},
					});
				}
			} catch (error) {
				// Re-enables draggables
				Inventory.EnableDraggables();

				/**
				 * If the request fails
				 */
				return InventoryNotify.Events.Process({
					process: 'notification',
					icon: 'fas fa-times-circle',
					color: '#ff0000',
					message: Language.Locale('unableToComplete'),
				});
			}
		},

		/**
		 * Buys an item from a store
		 * @param {string} slotInfo (Ex. External-1)
		 * @returns
		 */
		Buy: async (slotInfo) => {
			let payload = {};

			payload.shop = {
				id: $(Inventory.Selectors.ExternalInventory).data('id'),
				name: $(Inventory.Selectors.ExternalInventory).data('name'),
				type: $(Inventory.Selectors.ExternalInventory).data('type'),
			};

			payload.itemData =
				Inventory.Utilities.ConvertSlotInformationFromString(slotInfo);
			payload.amount = $(`#${slotInfo}-amount-value`).val();

			if (!payload.amount || parseInt(payload.amount) < 1) {
				return InventoryNotify.Events.Process({
					process: 'notification',
					icon: 'fas fa-times-circle',
					color: '#ff0000',
					message: Language.Locale('unableToComplete'),
				});
			}

			if (!payload.itemData.item) {
				return InventoryNotify.Events.Process({
					process: 'notification',
					icon: 'fas fa-times-circle',
					color: '#ff0000',
					message: Language.Locale('unableToComplete'),
				});
			}

			/**
			 * Process the moving
			 */
			try {
				const res = await Nui.request('buy', payload);

				/**
				 * If payload expected is not returned
				 */
				if (!res.success) {
					if (res.message) {
						InventoryNotify.Events.Process({
							process: 'notification',
							icon: 'fas fa-times-circle',
							color: '#ff0000',
							message: res.message,
						});
					}
				}
			} catch (error) {
				/**
				 * If the request fails
				 */
				InventoryNotify.Events.Process({
					process: 'notification',
					icon: 'fas fa-times-circle',
					color: '#ff0000',
					message: Language.Locale('unableToComplete'),
				});
			}
		},

		/**
		 * Craft an item
		 * @param {string} slotInfo (Ex. External-1)
		 * @returns
		 */
		Craft: async (slotInfo, amount) => {
			let payload = {};

			payload.crafting = {
				id: $(Inventory.Selectors.ExternalInventory).data('id'),
				name: $(Inventory.Selectors.ExternalInventory).data('name'),
				type: $(Inventory.Selectors.ExternalInventory).data('type'),
			};

			payload.amount = amount;
			payload.itemData =
				Inventory.Utilities.ConvertSlotInformationFromString(slotInfo);

			/**
			 * Process the moving
			 */
			try {
				const res = await Nui.request('craft', payload);

				/**
				 * If payload expected is not returned
				 */
				if (!res.success) {
					if (res.message) {
						InventoryNotify.Events.Process({
							process: 'notification',
							icon: 'fas fa-times-circle',
							color: '#ff0000',
							message: res.message,
						});
					}
				}
			} catch (error) {
				/**
				 * If the request fails
				 */
				InventoryNotify.Events.Process({
					process: 'notification',
					icon: 'fas fa-times-circle',
					color: '#ff0000',
					message: Language.Locale('unableToComplete'),
				});
			}
		},
	},

	/**
	 * Setup methods
	 */
	Setup: {
		SetExternalItems: (data, slots) => {
			if (data.external?.items) {
				if (Array.isArray(data.external.items)) {
					Inventory.State.ExternalItems = data.external.items;

					/**
					 * Finalize rendering
					 */
					Inventory.RenderSlots(
						'External',
						slots,
						Inventory.State.ExternalItems,
						data.external.type
					);

					// Update weights
					Inventory.UpdateInventoryWeights(
						'External',
						data.external.type
					);
				}
			}
		},
		/** Set creafting types */
		SetExternalTypes: (data) => {
			if (data.external?.type) {
				$(Inventory.Selectors.ExternalInventory).data(
					'type',
					data.external.type
				);

				if (data.external.type !== 'crafting') {
					$(Inventory.Selectors.ExternalInventory).removeClass(
						'height-includes-crafting-queue'
					);
					$(
						Inventory.Selectors.ExternalInventory + ' .box'
					).removeClass('height-includes-crafting-queue');
					$(Inventory.Selectors.CraftingQueue).hide();

					return;
				}

				$(Inventory.Selectors.ExternalInventory).addClass(
					'height-includes-crafting-queue'
				);
				$(Inventory.Selectors.ExternalInventory + ' .box').addClass(
					'height-includes-crafting-queue'
				);
				$(Inventory.Selectors.CraftingQueue).show();
			}
		},
		/** Set weight */
		SetExternalWeight: (data) => {
			if (data.external?.weight) {
				Inventory.State.Configuration.MaxExternalInventoryWeight =
					data.external.weight;
			}
		},
		/** Set id */
		SetExternalId: (data) => {
			if (data.external?.id) {
				$(Inventory.Selectors.ExternalInventory).data(
					'id',
					data.external.id
				);
			}
		},
		/** Set name */
		SetExternalName: (data) => {
			if (data.external?.name) {
				$(Inventory.Selectors.Titles.ExternalInventory).html(
					data.external.name
				);
				$(Inventory.Selectors.ExternalInventory).data(
					'name',
					data.external.name
				);
			}
		},
		SetExternalSlots: (data) => {
			if (data.external?.slots) {
				slots = data.external.slots;
			}
		},

		/**
		 * External inventory setup
		 * @param {object} data
		 */
		ExternalInventory: (data) => {
			let slots = Inventory.State.Configuration.MaxExternalInventorySlots;

			/**
			 * Set slots
			 */
			if (data.external?.slots) {
				Inventory.State.Configuration.MaxExternalInventorySlots =
					data.external.slots;
				slots = Inventory.State.Configuration.MaxExternalInventorySlots;
			}

			Inventory.Setup.SetExternalWeight(data);
			Inventory.Setup.SetExternalWeight(data);
			Inventory.Setup.SetExternalId(data);
			Inventory.Setup.SetExternalTypes(data);
			Inventory.Setup.SetExternalName(data);
			Inventory.Setup.SetExternalItems(data, slots);

			$(Inventory.Selectors.ExternalInventory).fadeIn();
		},
	},

	/**
	 * Updates the inventory weights on the ui
	 * @param {string} inventory
	 */
	UpdateInventoryWeights: (inventory, type) => {
		// Check type passed
		if (typeof type !== 'undefined') {
			if (type == 'shop' || type == 'crafting') {
				$('#external-weights').hide();
				return false;
			}
		}

		// Check type set in dom already
		const externalType = $(Inventory.Selectors.ExternalInventory).data(
			'type'
		);
		if (externalType == 'crafting' || externalType == 'shop') {
			$('#external-weights').hide();
			return false;
		}

		let totalWeight = Inventory.GetTotalWeight(inventory);
		let maxWeight = Inventory.GetMaxWeight(inventory);

		let percent = 0;

		if (totalWeight > 0 && maxWeight > 0) {
			if (totalWeight > 0) {
				percent = Math.ceil((totalWeight / maxWeight) * 100);
			}
		}

		$(
			Inventory.Selectors.Weights[
				`${inventory == 'External' ? 'External' : ''}InventoryWeight`
			]
		).html(Inventory.GetTotalWeight(inventory));
		$(
			Inventory.Selectors.Weights[
				`${inventory == 'External' ? 'External' : ''}InventoryMaxWeight`
			]
		).html(Inventory.GetMaxWeight(inventory));
		Inventory.SetWeightCirculars(inventory, percent);
		$('#external-weights').css('display', 'flex');
	},

	/**
	 * Updates player information on inventory
	 * @param {object} data
	 */
	UpdatePlayerInformation: (data) => {
		Inventory.State.Player = {
			...Inventory.State.Player,
			...data,
		};

		if (typeof data.name !== 'undefined') {
			$(Inventory.Selectors.Titles.PlayerName).html(
				Inventory.State.Player.name
			);
			$(Inventory.Selectors.Titles.MyInventory)
				.data('id', Inventory.State.Player.identifier)
				.html(data.name);
		}

		if (typeof data.preferences !== 'undefined') {
			if (data.preferences.theme) {
				Inventory.Settings.SetTheme(data.preferences.theme);
			}
		}
	},

	/**
	 * Formatted weight of inventory
	 * @param {string} inv
	 * @returns {int}
	 */
	GetTotalWeight: (inv) => {
		let weight = 0;

		if (inv == 'Inventory') {
			for (let i = 0; i < Inventory.State.Items.length; i++) {
				const item = Inventory.State.Items[i];
				if (item) {
					weight += item.weight * item.amount;
				}
			}
		} else if (inv == 'External') {
			for (let i = 0; i < Inventory.State.ExternalItems.length; i++) {
				const item = Inventory.State.ExternalItems[i];
				if (item) {
					weight += item.weight * item.amount;
				}
			}
		} else {
			return weight;
		}

		return weight > 0 ? weight / 1000 : 0;
	},

	/**
	 * Return formatted max weight
	 * @param {string} inv
	 * @returns {int}
	 */
	GetMaxWeight: (inv) => {
		if (inv == 'Inventory') {
			return Inventory.State.Configuration.MaxInventoryWeight / 1000;
		} else if (inv == 'External') {
			return (
				Inventory.State.Configuration.MaxExternalInventoryWeight / 1000
			);
		}

		return 0;
	},

	/**
	 * Gets an item by it's slot number from the inventory
	 * items passed
	 * @param {int} slot
	 * @param {array} items
	 * @returns {object}
	 */
	GetItemBySlot: (slot, items = false) => {
		items = items ? items : Inventory.State.Items;
		if (!items) items = [];
		let item = false;

		for (let i = 0; i < items.length; i++) {
			if (items[i]) {
				if (items[i].slot == slot) {
					item = items[i];
				}
			}
		}

		return item;
	},

	/**
	 * Updates item by slot number
	 * @param {int} slot
	 * @param {string} key
	 * @param {mixed} value
	 */
	UpdateItemBySlot: (slot, key, value, inventory) => {
		items =
			inventory == 'External'
				? Inventory.State.ExternalItems
				: Inventory.State.Items;
		if (!items) items = [];

		for (let i = 0; i < items.length; i++) {
			if (!items[i] && items[i].slot !== slot) {
				continue;
			}

			const updatedItem = {
				...items[i],
				[key]: value,
			};

			if (inventory === 'External') {
				Inventory.State.ExternalItems[i] = updatedItem;
			} else {
				Inventory.State.Items[i] = updatedItem;
			}
		}
	},

	/**
	 * Renders slots for a specific inventory
	 * type.
	 * @param {string} inv
	 * @param {int} count
	 * @param {array} items
	 */
	RenderSlots: (inv, count, items = [], type = 'slot') => {
		// Reset dom, draggable, and droppables
		Inventory.ClearEventHandlers();
		$(Inventory.Selectors[inv]).html('');

		// Index of slots to start at
		let startingIndex = 0;

		// Set Inventory to 5 because of the hot bar
		if (inv == 'Inventory') {
			startingIndex = 5;
		}

		if (inv == 'Hot') {
			$(Inventory.Selectors['BottomHot']).html('');
		}

		// Iterate through each slot and check if an item exists for it
		for (let i = startingIndex; i < count; i++) {
			let item = Inventory.GetItemBySlot(
				i + 1,
				Array.isArray(items) ? items : []
			);

			if (inv == 'External' && type == 'shop') {
				$(Inventory.Selectors[inv]).append(
					Inventory.Templates.ShopItem(
						inv,
						i + 1,
						item ? item : false
					)
				);
			} else if (inv == 'External' && type == 'crafting') {
				$(Inventory.Selectors[inv]).append(
					Inventory.Templates.CraftItem(
						inv,
						i + 1,
						item ? item : false
					)
				);
			} else {
				$(Inventory.Selectors[inv]).append(
					Inventory.Templates.Slot(
						inv,
						i + 1,
						item ? item : false,
						inv != 'Hot' ? '5ths' : false
					)
				);

				if (inv == 'Hot') {
					$(Inventory.Selectors['BottomHot']).append(
						Inventory.Templates.Slot(
							'BottomHot',
							i + 1,
							item ? item : false,
							'5ths'
						)
					);
				}
			}
		}

		Inventory.SetEventHandlers();
	},

	/**
	 * Updates slot display information
	 * @param {string} inventory
	 * @param {int} slotId
	 * @param {object} newData
	 * @returns {boolean}
	 */
	UpdateSlotMetaData: (inventory, slotId, newData) => {
		const slot = `.slot[data-slotid="${inventory}-${slotId}"]`;

		if (!$(slot).length) {
			return false;
		}

		if (newData.amount) {
			$(`${slot} .amount`).html(newData.amount + 'x');
		}

		if (newData.name) {
			$(`${slot} .name`).html(newData.label + 'x');
		}

		return true;
	},

	/**
	 * Inventory templates to write to the dom.
	 */
	Templates: {
		/**
		 * Slot template
		 * @param {int} slotNumber
		 * @param {mixed} data
		 * @param {mixed} columnSize
		 * @returns {string}
		 */
		Slot: (inv, slotNumber, data = false, columnSize = false) => {
			let inventoryType = 'player';

			let wrapper = columnSize
				? `<div class="col-${columnSize}">{slot}</div>`
				: `{slot}`;
			let slot = `<div class="slot-container ${
				(slotNumber > 0) & (slotNumber < 6) & (inv == 'Hot')
					? 'limited'
					: ''
			}" data-slotid="${inv}-${slotNumber}">{slotMeta}</div>`;
			let slotMeta = '';

			if (typeof data.info == 'undefined') {
				data.info = {
					quality: 100,
				};
			}

			// If there is an item for this slot
			if (data) {
				slotMeta = `
                    <div data-inventory="${inventoryType}" class="slot ${
					(slotNumber > 0) & (slotNumber < 6) & (inv == 'Hot')
						? 'limited'
						: ''
				} ripple" data-slotid="${inv}-${slotNumber}">
                        <div style="background-image: url('nui://${GetParentResourceName()}/nui/assets/images/${
					data.image
				}');" class="image"></div>
                        ${
							typeof data.amount !== 'undefined'
								? `<div class="amount">${data.amount}x</div>`
								: ''
						}
                        <div class="name">${data.label}</div>
                        <div class="durability" ${
							typeof data.info.quality !== 'undefined'
								? `style="width: ${data.info.quality}%;"`
								: ''
						}></div>
                    </div>
                `;
			}

			slot = slot.replace('{slotMeta}', slotMeta);
			wrapper = wrapper.replace('{slot}', slot);

			return wrapper;
		},

		/**
		 * Slot template
		 * @param {int} slotNumber
		 * @param {mixed} data
		 * @returns {string}
		 */
		ShopItem: (inv, slotNumber, data = false) => {
			return `
                <div class="col-12">
                    <div class="shop-item" data-slotid="${inv}-${slotNumber}">
                        <div style="background-image: url('nui://${GetParentResourceName()}/nui/assets/images/${
				data.image
			}');" class="image"></div>
                        <div class="name">${data.label}</div>
                        <div class="options">
                            <span class="badge text-bg-dark">$${
								data.price
							}</span>
                            <input ${
								data.unique == true ? 'readonly="readonly"' : ''
							} id="${inv}-${slotNumber}-amount-value" type="number" value="1" class="form-control d-inline-block" style="width: 70px;position: relative; top: 2px; text-align: center;" />
                            <a onclick="Inventory.Events.Buy('${inv}-${slotNumber}');" class="btn btn-success d-inline-block" href="javascript:void(0);">Buy</a>
                        </div>
                    </div>
                </div>
            `;
		},

		/**
		 * Craft item template
		 * @param {int} slotNumber
		 * @param {mixed} data
		 * @returns {string}
		 */
		CraftItem: (inv, slotNumber, data = false) => {
			let recipe = '';
			for (let i = 0; i < data.crafting.materials.length; i++) {
				const item = data.crafting.materials[i];
				recipe += `<li class="list-group-item">${item.item} x${item.amount}</li>`;
			}

			return `
                <div class="col-6">
                    <div class="craft-item" id="craft-item-${slotNumber}" data-slotid="${inv}-${slotNumber}">
                        <div class="w-100 mb-3 text-center">
                            <image src="nui://${GetParentResourceName()}/nui/assets/images/${
				data.image
			}" />
                        </div>
                        <div class="w-100 text-center mb-2">${
							data.label
						} <span class="badge text-bg-light">x1</span></div>
                        <div class="w-100">
                            <a onclick="Inventory.Events.Craft('${inv}-${slotNumber}', ${
				data.crafting.amount
			});" class="btn btn-success d-inline-block w-100 fw-bold" href="javascript:void(0);">Craft Item</a>
                        </div>
                        <div class="time">
                            ${data.crafting.time} seconds
                        </div>
                        <div class="crafting-info">
                            <ul class="list-group">
                                ${recipe}
                            </ul>
                        </div>
                        <div class="info" onclick="$('#craft-item-${slotNumber} .crafting-info').fadeToggle();">
                            <i class="fas fa-info-circle"></i>
                        </div>
                    </div>
                </div>
            `;
		},

		CraftQueueItem: (data) => {
			return `
                <div class="craft-slot-container" data-id="${data.queueId}">
                    <div class="craft-slot">
                        <div style="background-image: url('nui://${GetParentResourceName()}/nui/assets/images/${
				data.item.image
			}');" class="image"></div>
                        <div class="amount">${data.amount}x</div>
                        <div class="name">${data.item.label}</div>
                        <div class="durability" data-current="${
							data.item.crafting.time
						}" data-max="${data.item.crafting.time}"></div>
                    </div>
                </div>
            `;
		},
	},

	/**
	 * Removes draggable and droppable events
	 * before re-rendering
	 */
	ClearEventHandlers: () => {
		$(document).off('dblclick', '.slot');
		$(document).off('click', '.slot');

		if (Inventory.State.DraggablesRegistered) {
			$('.slot').draggable('destroy');
			$('.slot-container').droppable('destroy');
			Inventory.State.DraggablesRegistered = false;
		}
	},

	/**
	 * Sets drag and drop events after render
	 */
	SetEventHandlers: () => {
		/**
		 * Handle double clicking of slot to use
		 */
		$(document).on('dblclick', '.slot', function () {
			const item = $(this);
			const slotData = item.data('slotid').split('-');
			const inventoryType = item.data('inventory');

			if (slotData.length == 2) {
				const slotId = slotData[1];
				const itemData = Inventory.GetItemBySlot(slotId);

				if (itemData) {
					if (!itemData.useable && itemData.type !== 'weapon') return;

					if (itemData.useable || itemData.type == 'weapon') {
						if (itemData.shouldClose || itemData.type == 'weapon') {
							Nui.request('close');
						}

						Inventory.Events.OnUse(slotId, inventoryType, itemData);
					}
				}
			}
		});

		// Setup the draggable slots
		$('.slot').draggable({
			revert: 'invalid',
			scroll: false,
			zIndex: 100,
			appendTo: 'body',
			helper: 'clone',
			start: (event, ui) => {
				if (Inventory.State.BootstrapMenu) {
					Inventory.State.BootstrapMenu.close();
				}

				$(ui.helper)
					.css('width', `${$(event.target).width()}px`)
					.css('height', `${$(event.target).height()}px`);

				$('.actionable').show();
			},
			stop: () => {
				$('.actionable').fadeOut();
			},
		});

		// Handle drops
		$('.slot-container').droppable({
			accept: '.slot',
			tolerance: 'intersect',
			hoverClass: 'active-border',
			drop: (event, ui) => {
				/**
				 * Get all variables for logic
				 */
				let $item = ui.draggable.detach();
				let $target = $(event.target);
				let oldSlotId = $item.data('slotid');
				let oldSlotIdNumeric = oldSlotId.split('-')[1];
				let oldSlotInventory = oldSlotId.split('-')[0]; // Hot, Inventory, External
				let oldItem = Inventory.GetItemBySlot(
					oldSlotIdNumeric,
					oldSlotInventory == 'External'
						? Inventory.State.ExternalItems
						: false
				);
				let newSlotId = $target.data('slotid');
				let newSlotIdNumeric = newSlotId.split('-')[1];
				let newSlotInventory = newSlotId.split('-')[0]; // Hot, Inventory, External
				let newItem = Inventory.GetItemBySlot(
					newSlotIdNumeric,
					newSlotInventory == 'External'
						? Inventory.State.ExternalItems
						: false
				);
				let stacked = false;

				// If an item is there, swap with the external
				if ($target.find('.slot').length) {
					let swapItem = $target.find('.slot')[0];
					let slotId = $item.data('slotid');

					/**
					 * If the old item and the new item are the same and is not
					 * unique. Handle "stacking"
					 */
					if (
						oldItem.name == newItem.name &&
						!oldItem.unique &&
						!newItem.unique
					) {
						Inventory.UpdateSlotMetaData(
							newSlotInventory,
							newSlotId,
							{
								amount: oldItem.amount + newItem.amount,
							}
						);

						stacked = true;
					} else {
						// Update new slot to old slot id
						$(swapItem).data('slotid', oldSlotId);
						Inventory.UpdateItemBySlot(
							newSlotIdNumeric,
							'slot',
							oldSlotIdNumeric,
							newSlotInventory
						);
						$(swapItem)
							.detach()
							.appendTo(
								$(`.slot-container[data-slotid="${slotId}"]`)
							);
					}
				}

				$item.attr('style', '');

				if (!stacked) {
					// Update old slot to new slot id
					$item.data('slotid', newSlotId);
					Inventory.UpdateItemBySlot(
						oldSlotIdNumeric,
						'slot',
						newSlotIdNumeric,
						oldSlotInventory
					);
					$item.appendTo($target);
				} else {
					$item.remove();
				}

				Inventory.Events.Move({
					from: oldSlotInventory,
					to: newSlotInventory,
					fromSlotId: oldSlotIdNumeric,
					toSlotId: newSlotIdNumeric,
					oldItem: oldItem,
					newItem: newItem,
				});
			},
		});

		/**
		 * Check if bootstrap menu is registered
		 */
		if (!Inventory.State.BootstrapMenu) {
			/**
			 * Register the bootstrap menu
			 */
			Inventory.State.BootstrapMenu = new BootstrapMenu(
				`${Inventory.Selectors.Hot} .slot, ${Inventory.Selectors.Inventory} .slot`,
				{
					fetchElementData: function ($el) {
						return $el;
					},
					actions: [
						{
							render: ($el) => {
								const item = $el;
								const slotData = item.data('slotid').split('-');
								const inventoryType = item.data('inventory');

								if (slotData.length == 2) {
									const slotId = slotData[1];
									const itemData =
										Inventory.GetItemBySlot(slotId);

									let showAttachmentsList = false;
									if (itemData.info) {
										if (itemData.info.attachments) {
											showAttachmentsList = true;
										}
									}

									if (itemData) {
										return `
                                        <div>
                                            <div class="item-menu-title">${
												itemData.label
											}</div>
                                            ${
												itemData.description
													? `<div class="item-menu-subtitle">${itemData.description}</div>`
													: ''
											}
                                            <div class="w-100 text-center">
                                                <img width="60%" height="auto" src="nui://${GetParentResourceName()}/nui/assets/images/${
											itemData.image
										}" />
                                            </div>
                                            ${
												showAttachmentsList
													? `
                                                <div class="w-100 py-1">
                                                    ${Inventory.Utilities.BuildAttachmentsList(
														itemData,
														itemData.info
															.attachments
													)}
                                                </div>
                                            `
													: ''
											}
                                            ${Inventory.Utilities.BuildInformationList(
												itemData
											)}
                                            ${
												itemData.amount > 1
													? `
                                                <hr />
                                                <div class="w-100 d-flex justify-content-between align-items-center">
                                                    <div class="w-100">
                                                        <input oninput="Inventory.Utilities.UpdateAmountBadge(event, this, '#slot-${slotId}-amount-badge');" style="position: relative;top: 3px;" type="range" class="form-range ranger" value="${itemData.amount}" steps="1" min="1" max="${itemData.amount}" id="slot-${slotId}-amount">
                                                    </div>
                                                    <div class="ms-2">
                                                        <span id="slot-${slotId}-amount-badge" class="badge badge-dark">${itemData.amount}</span>
                                                    </div>
                                                </div>
                                            `
													: ''
											}
                                        </div>
                                    `;
									}
								}
							},
						},
						{
							name: Language.Locale('split'),
							onClick: function ($el) {
								const item = $el;
								const slotData = item.data('slotid').split('-');
								const inventoryType = item.data('inventory');

								if (slotData.length == 2) {
									const slotId = slotData[1];
									const itemData =
										Inventory.GetItemBySlot(slotId);

									if (itemData) {
										const amountElement = $(
											`#slot-${slotId}-amount`
										);
										if (amountElement.length) {
											itemData.amount = parseInt(
												$(
													`#slot-${slotId}-amount`
												).val()
											);
										}

										Inventory.Events.Split({
											slot: slotId,
											inventory: inventoryType,
											item: itemData,
										});
									}
								}
							},
							isEnabled: function ($el) {
								const item = $el;
								const slotData = item.data('slotid').split('-');

								if (slotData.length == 2) {
									const slotId = slotData[1];
									const itemData =
										Inventory.GetItemBySlot(slotId);

									if (itemData) {
										if (parseInt(itemData.amount) > 1) {
											return true;
										} else {
											return false;
										}
									} else {
										return false;
									}
								} else {
									return false;
								}
							},
						},
						{
							name: Language.Locale('use'),
							onClick: function ($el) {
								const item = $el;
								const slotData = item.data('slotid').split('-');
								const inventoryType = item.data('inventory');

								if (slotData.length == 2) {
									const slotId = slotData[1];
									const itemData =
										Inventory.GetItemBySlot(slotId);

									if (itemData) {
										const amountElement = $(
											`#slot-${slotId}-amount`
										);
										if (amountElement.length) {
											itemData.amount = parseInt(
												$(
													`#slot-${slotId}-amount`
												).val()
											);
										}

										if (
											itemData.useable ||
											itemData.type == 'weapon'
										) {
											if (
												itemData.shouldClose ||
												itemData.type == 'weapon'
											) {
												Nui.request('close');
											}

											Inventory.Events.OnUse(
												slotId,
												inventoryType,
												itemData
											);
										}
									}
								}
							},
							isEnabled: function ($el) {
								const item = $el;
								const slotData = item.data('slotid').split('-');

								if (slotData.length == 2) {
									const slotId = slotData[1];
									const itemData =
										Inventory.GetItemBySlot(slotId);

									if (itemData) {
										if (itemData.name.includes('ammo')) {
											return false;
										}

										if (
											itemData.useable ||
											itemData.type == 'weapon'
										) {
											return true;
										} else {
											return false;
										}
									} else {
										return false;
									}
								} else {
									return false;
								}
							},
						},
						{
							name: Language.Locale('give'),
							onClick: function ($el) {
								const item = $el;
								const slotData = item.data('slotid').split('-');
								const inventoryType = item.data('inventory');

								if (slotData.length == 2) {
									const slotId = slotData[1];
									const itemData =
										Inventory.GetItemBySlot(slotId);

									if (itemData) {
										const amountElement = $(
											`#slot-${slotId}-amount`
										);
										if (amountElement.length) {
											itemData.amount = parseInt(
												$(
													`#slot-${slotId}-amount`
												).val()
											);
										}

										Inventory.Events.Give({
											slot: slotId,
											inventory: inventoryType,
											item: itemData,
										});
									}
								}
							},
						},
						{
							name: Language.Locale('drop'),
							onClick: function ($el) {
								const item = $el;
								const slotData = item.data('slotid').split('-');

								if (slotData.length !== 2) {
									return;
								}

								const inventoryType = item.data('inventory');
								const slotId = slotData[1];
								const itemData =
									Inventory.GetItemBySlot(slotId);

								if (!itemData) {
									return;
								}

								const amountElement = $(
									`#slot-${slotId}-amount`
								);

								if (amountElement.length) {
									itemData.amount = parseInt(
										$(`#slot-${slotId}-amount`).val()
									);
								}

								Inventory.Events.Drop({
									slot: slotId,
									inventory: inventoryType,
									item: itemData,
								});
							},
						},
					],
				}
			);
		}

		// Set draggables as registered
		Inventory.State.DraggablesRegistered = true;
	},

	/**
	 * Temporarily disables draggables
	 */
	DisableDraggables: () => {
		if ($('.slot').hasClass('ui-droppable')) {
			$('.slot').draggable('disable');
		}
	},

	/**
	 * Temporarily enables draggables
	 */
	EnableDraggables: () => {
		if ($('.slot').hasClass('ui-droppable')) {
			$('.slot').draggable('enable');
		}
	},

	/**
	 * Sets the circular progress bar for inventory weights
	 * @param {string} inventory
	 * @param {int} percent
	 */
	SetWeightCirculars: (inventory, percent) => {
		$('.progress.' + inventory).each(function () {
			$(this).attr('data-value', percent);

			var value = $(this).attr('data-value');
			var left = $(this).find('.progress-left .progress-bar');
			var right = $(this).find('.progress-right .progress-bar');

			if (value <= 50) {
				right.css(
					'transform',
					'rotate(' +
						Inventory.Utilities.PercentToDegress(value) +
						'deg)'
				);
			} else {
				right.css('transform', 'rotate(180deg)');
				left.css(
					'transform',
					'rotate(' +
						Inventory.Utilities.PercentToDegress(value - 50) +
						'deg)'
				);
			}
		});
	},

	/**
	 * Utility functions for inventory
	 */
	Utilities: {
		ConvertCamelCaseToWords: (text) => {
			const result = text.replace(/([A-Z])/g, ' $1');
			return result.charAt(0).toUpperCase() + result.slice(1);
		},

		/**
		 * Lists additional item information if applicable
		 * @param {object} itemData
		 */
		BuildInformationList: (itemData) => {
			let res = '<div class="w-100 py-2">{{info}}</div>';
			let info = '';
			let ignore = ['quality', 'decayed', 'attachments'];
			if (typeof itemData.info == 'undefined') {
				return '';
			}
			if (!itemData.info) {
				return '';
			}

			for (let infoKey in itemData.info) {
				if (ignore.includes(infoKey)) {
					continue;
				}

				let field =
					Inventory.Utilities.ConvertCamelCaseToWords(infoKey);
				if (field == 'Serie') {
					field = 'Serial #';
				}

				info += `
                    <div class="w-100 d-flex justify-content-between align-items-center text-start p-2 border-rounded" style="background: rgba(255, 255, 255, 0.1);font-size: 11px;">
                        <div class="w-50">
                            ${field}
                        </div>

                        <div class="w-50 text-end">
                            ${itemData.info[infoKey]}
                        </div>
                    </div>
                `;
			}

			if (info == '') {
				return '';
			}
			return res.replace('{{info}}', info);
		},

		/**
		 * Builds attachment list for weapon attachments
		 * @param {array} attachments
		 */
		BuildAttachmentsList: (itemData, attachments) => {
			let res = '';

			if (Array.isArray(attachments)) {
				if (attachments.length) {
					for (let i = 0; i < attachments.length; i++) {
						res += `
                            <div class="w-100 d-flex justify-content-between align-items-center text-start p-2 border-rounded" style="background: rgba(255, 255, 255, 0.1);">
                                <div class="w-100">
                                    ${attachments[i].label}
                                </div>
                                <div>
                                    <button onclick="Inventory.Events.RemoveAttachment('${itemData.slot}', '${attachments[i].item}', '${attachments[i].component}')" type="button" class="btn btn-xs btn-danger"><i class="fas fa-minus-circle"></i></button>
                                </div>
                            </div> 
                        `;
					}
				}
			}

			return res;
		},

		/**
		 * Updates amount badge for item amount slider in context menu
		 * @param {event} e
		 * @param {element} el
		 * @param {string} target
		 */
		UpdateAmountBadge: (e, el, target) => {
			e.preventDefault();
			const amount = $(el).val();
			$(target).html(amount);
		},

		/**
		 * Converts "Inventory-1" to { slot: 1, inventory: "Inventory", item { ... }}
		 * @param {string} slotInfo
		 * @returns {object}
		 */
		ConvertSlotInformationFromString: (slotInfo) => {
			let slot = slotInfo.split('-')[1];
			let inventory = slotInfo.split('-')[0]; // Hot, Inventory, External
			let item = Inventory.GetItemBySlot(
				slot,
				inventory == 'External' ? Inventory.State.ExternalItems : false
			);

			return {
				slot: slot,
				inventory: inventory,
				item: item,
			};
		},

		/**
		 * Converts percentage to degrees
		 * @param {int} percentage
		 * @returns {int}
		 */
		PercentToDegress: (percentage) => {
			return (percentage / 100) * 360;
		},

		/**
		 * Adds item to crafting queue
		 */
		AddCraftingQueueItem: (data) => {
			$(Inventory.Selectors.CraftingQueue).append(
				Inventory.Templates.CraftQueueItem(data)
			);
		},

		StartCraftingQueueTimer: (id) => {
			if (Inventory.State.CraftingQueueTimer[id]) {
				return false;
			}

			/**
			 * Interval to visually track time to completion
			 */
			Inventory.State.CraftingQueueTimer[id] = setInterval(() => {
				const el = `.craft-slot-container[data-id="${id}"]`;

				if ($(el).length) {
					let current = parseInt(
						$(`${el} .durability`).data('current')
					);
					const max = parseInt($(`${el} .durability`).data('max'));

					if (current > 0) {
						current = current - 1;
						const percent = (current / max) * 100;

						$(`${el} .durability`).data('current', current);
						$(`${el} .durability`).css('width', `${percent}%`);
					}

					if (current == 0) {
						Inventory.Utilities.RemoveCraftingQueueItem(id);

						if (Inventory.State.CraftingQueueTimer[id]) {
							delete Inventory.State.CraftingQueueTimer[id];
						}
					}
				}
			}, 1000);
		},

		/**
		 * Removes items from crafting queue
		 */
		RemoveCraftingQueueItem: (id) => {
			$('.craft-slot-container[data-id="' + id + '"]').remove();

			if (Inventory.State.CraftingQueueTimer[id]) {
				delete Inventory.State.CraftingQueueTimer[id];
			}
		},
	},

	/**
	 * Methods for setting handlers
	 */
	Settings: {
		/**
		 * Hide the hotbar
		 */
		DisableHotbar: () => {
			$(Inventory.Selectors.BottomHotContainer).fadeOut();
		},

		/**
		 * Enable hotbar only if state is enabled
		 */
		EnableHotbar: () => {
			if (Inventory.State.Hotbar) {
				$(Inventory.Selectors.BottomHotContainer).fadeIn();
			}
		},

		/**
		 * Toggles hotbar based on current state
		 */
		ToggleHotbar: () => {
			Inventory.State.Hotbar = !Inventory.State.Hotbar;

			if (Inventory.State.Hotbar) {
				$(Inventory.Selectors.BottomHotContainer).fadeIn();
			} else {
				$(Inventory.Selectors.BottomHotContainer).fadeOut();
			}
		},

		/**
		 * Builds themes as options in settings modal
		 */
		BuildThemes: (themes) => {
			Inventory.Themes = themes;
			$('#settings-themes').html('');

			for (let theme in themes) {
				$('#settings-themes').append(
					`
                    <div class="col-lg-3">
                        <div class="color-box" data-theme="${theme}" style="background: ${themes[theme].color} !important;"></div>
                    </div>
                    `
				);
			}
		},

		/**
		 * Sets the inventory theme
		 */
		SetTheme: (theme) => {
			if (typeof Inventory.Themes[theme] == 'undefined') {
				return false;
			}
			$('body')
				.get(0)
				.style.setProperty(
					'--ui-highlight-color',
					Inventory.Themes[theme].color
				);

			if (Inventory.Themes[theme].shadowColor) {
				$('body')
					.get(0)
					.style.setProperty(
						'--ui-highlight-box-shadow-color',
						Inventory.Themes[theme].shadowColor
					);
			}

			if (Inventory.Themes[theme].borderRadius) {
				$('body')
					.get(0)
					.style.setProperty(
						'--ui-border-radius',
						`${Inventory.Themes[theme].borderRadius}px`
					);
			}
		},

		/**
		 * Registers the handler for changing color scheme.
		 */
		RegisterColorPickerHandler: () => {
			$(document).on('click', '.color-box', function (e) {
				e.preventDefault();
				Inventory.Settings.SetTheme($(this).data('theme'));

				Nui.request('saveInventoryPreferences', {
					theme: $(this).data('theme'),
				});
			});
		},
	},
};
