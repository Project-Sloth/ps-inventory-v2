/**
 * Framework for Interactions
 */
const Interact = {
	State: {
		Show: false,
	},

	/**
	 * Selectors for interactions
	 */
	Selectors: {
		Interact: '#interact',
		MessageContainer: '#interact .message',
	},

	Events: {
		/**
		 * Shows interaction alert
		 * @param {object} data
		 */
		Show: (data = false) => {
			// If re-opening because state was set already
			if (!data && Interact.State.Show) {
				$(Interact.Selectors.MessageContainer).fadeIn();
			}

			$(Interact.Selectors.MessageContainer).html(data.message);
			$(Interact.Selectors.MessageContainer).fadeIn();
			Interact.State.Show = true;
		},

		/**
		 * Hides interaction alert
		 */
		Hide: (updateState = true) => {
			$(Interact.Selectors.MessageContainer).fadeOut();
			if (updateState) {
				Interact.State.Show = false;
			}
		},
	},
};
