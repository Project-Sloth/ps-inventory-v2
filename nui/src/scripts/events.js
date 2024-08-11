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
        if (typeof data.debugging !== "undefined") {
            Debugger.enabled = data.debugging
        }

        if (typeof data.player !== "undefined") {
            Debugger.log(JSON.stringify(data.player));
            Inventory.UpdatePlayerInformation(data.player);
        }

        if (typeof data.inventory !== "undefined") {
            Inventory.State.Configuration = {
                ...Inventory.State.Configuration,
                ...data.inventory
            };
        }

        InventoryNotify.Events.Process({
            process: "notification",
            icon: "fas fa-check-circle",
            color: "#beda17",
            message: "Inventory is ready for use"
        })
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
                        id: data.external.id
                    }
                })
            }
        }

        Inventory.Events.UpdateInventory(data);
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
        Inventory.Utilities.AddCraftingQueueItem(data)
    },

    /**
     * Removes a crafting queue item after completion or cancelation
     * @param {object} data 
     */
    removeCraftingQueueItem: (data) => {
        Inventory.Utilities.RemoveCraftingQueueItem(data.id)
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
        InventoryNotify.Events.Process(data)
    },

    /**
     * =============================================
     * INTERACTION EVENT
     * =============================================
     */

    interact: (data) => {

        switch (data.process) {

            case 'show':
                Interact.Events.Show(data)
                break;

            case 'hide':
                Interact.Events.Hide();
                break;
        }
    }
}