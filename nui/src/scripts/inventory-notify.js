/**
 * Framework for Inventory Notifications
 */
const InventoryNotify = {
	/**
	 * Selectors of the dom for inventory types
	 */
	Selectors: {
		ToastContainer: '.inventory-toasts-container',
	},

	State: {
		OldHeight: 0,
	},

	Events: {
		/**
		 * Processes inventory notification
		 * @param {object} data
		 * @param {int} delay
		 * @returns {mixed}
		 */
		Process: (data, delay = 5000) => {
			// Validate process
			const accaptedProcesses = ['add', 'remove', 'notification'];
			if (!accaptedProcesses.includes(data.process)) {
				return false;
			}

			// Retrieve the old container height
			const oldContainerHeight = $(
				InventoryNotify.Selectors.ToastContainer
			)[0].offsetHeight;

			// Create the toast and append it to the container
			const toast = $(InventoryNotify.Templates.Toast(data));
			$(InventoryNotify.Selectors.ToastContainer).append(toast);

			// Get the new height and difference
			const newContainerHeight = $(
				InventoryNotify.Selectors.ToastContainer
			)[0].offsetHeight;
			InventoryNotify.State.OldHeight =
				newContainerHeight - oldContainerHeight;

			// Animate the height of the container
			$(InventoryNotify.Selectors.ToastContainer)[0].height =
				newContainerHeight;
			$(InventoryNotify.Selectors.ToastContainer)[0].animate(
				{ transform: `translateY(-${newContainerHeight}px)` },
				{ duration: 250, fill: 'forwards' }
			);

			setTimeout(async () => {
				// Animate the toast out
				await toast[0].animate(
					{ transform: 'translateY(50%)', opacity: 0 },
					{ duration: 500, fill: 'forwards' }
				).finished;

				// Remove the toast
				toast.remove();

				// Calculate new container height and animate
				const newHeight =
					$(InventoryNotify.Selectors.ToastContainer)[0].height -
					InventoryNotify.State.OldHeight;
				$(InventoryNotify.Selectors.ToastContainer)[0].height =
					newHeight;

				$(InventoryNotify.Selectors.ToastContainer)[0].animate(
					{ transform: `translateY(${newHeight * -1}px)` },
					{ duration: 0, fill: 'forwards' }
				);
			}, delay);
		},
	},

	/**
	 * Templates for toast
	 */
	Templates: {
		/**
		 * Toast template
		 * @param {object} data
		 * @returns {string}
		 */
		Toast: (data) => {
			let message = '';

			if (data.process == 'add') {
				message = `Added ${data.amount} ${data.item.label}`;
			} else if (data.process == 'remove') {
				message = `Removed ${data.amount} ${data.item.label}`;
			} else if (data.process == 'notification') {
				message = data.message
					? data.message
					: Language.Locale('inventoryReady');
			}

			let output = `
                  <div class="inventory-toast">
                        <div class="notify-slot-container">
                            <div class="notify-slot ${
								data.process == 'notification'
									? 'notification'
									: ''
							}">
                                ${
									data.process == 'notification'
										? `<i style="${
												data.color
													? 'color: ' + data.color
													: ''
										  }" class="${
												data.icon
													? data.icon
													: 'fas fa-check-circle'
										  }"></i>`
										: `
                                    <div style="background-image: url('nui://${GetParentResourceName()}/nui/assets/images/${
												data.item.image
										  }');" class="image"></div>
                                    <div class="amount">${data.amount}x</div>
                                    <div class="name">${data.item.label}</div>
                                    <div class="durability"></div>
                                    `
								}
                            </div>
                        </div>
                        <div class="inventory-toast-inner">
                            <span>${message}</span>
                        </div> 
                  </div>
              `;

			return output;
		},
	},
};
