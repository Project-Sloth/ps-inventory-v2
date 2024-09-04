/**
 * Language methods
 */
const Language = {
	Locales: {},

	/**
	 * Sets the locales object
	 * @param {object} locales
	 */
	SetLocales: (locales) => {
		Language.Locales = locales;
		Debugger.log('Locales have been set.');
	},

	/**
	 * Retrieve locale and mergetags if applicable
	 * @param {string} key
	 * @param {object} mergeTags
	 * @returns
	 */
	Locale: (key, mergeTags = {}) => {
		if (!Language.Locales[key]) {
			return Debugger.log(`Unable to find Locale[${key}]`);
		}

		let locale = Language.Locales[key];

		if (mergeTags.length) {
			for (let tag in mergeTags) {
				locale = locale.replace(`{{${tag}}}`, mergeTags[tag]);
			}
		}

		return locale;
	},

	/**
	 * Merge tags into a string
	 * @param {string} message
	 * @param {object} mergeTags
	 * @returns {string}
	 */
	ProcessString: (message, mergeTags = {}) => {
		for (let tag in mergeTags) {
			message = message.replace(`{{${tag}}}`, mergeTags[tag]);
		}

		return message;
	},
};
