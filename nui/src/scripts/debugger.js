const Debugger = {
	enabled: true,

	log: (msg) => {
		if (Debugger.enabled) {
			console.log(
				'[Debugger]: ' + typeof msg == 'object' || Array.isArray(msg)
					? JSON.stringify(msg)
					: msg
			);
		}
	},
};
