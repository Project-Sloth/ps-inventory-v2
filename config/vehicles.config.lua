Config.Vehicles = {

    -- Overrides storage for vehicle classes
    ClassOverrides = {

        -- Compacts
        [0] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 30, MaxSlots = 38000 }
        },

        -- Sedans
        [1] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 40, MaxSlots = 50000 }
        },

        -- SUVs
        [2] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 50, MaxSlots = 75000 }
        },

        -- Coupes
        [3] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 25, MaxSlots = 42000 }
        },

        -- Muscle
        [4] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 30, MaxSlots = 30000 }
        },

        -- Sports Classics
        [5] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 25, MaxSlots = 30000 }
        },

        -- Sports
        [6] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 25, MaxSlots = 30000 }
        },

        -- Super
        [7] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 25, MaxSlots = 30000 }
        },

        -- Motorcycles
        [8] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 15, MaxSlots = 15000 }
        },

        -- Off-road
        [9] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 35, MaxSlots = 60000 }
        },

        -- Vans
        [12] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 35, MaxSlots = 10000 }
        },

        -- Cycles
        [13] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 0, MaxSlots = 0 }
        },

        -- Boats
        [14] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 50, MaxSlots = 120000 }
        },

        -- Helicopters
        [15] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 50, MaxSlots = 120000 }
        },

        -- Planes
        [16] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 5 },
            Trunk    = { MaxWeight = 50, MaxSlots = 120000 }
        },

        -- Service
        [17] = { 
            Glovebox = { MaxWeight = 0, MaxSlots = 0 },
            Trunk    = { MaxWeight = 0, MaxSlots = 0 }
        },

        -- Emergency
        [18] = { 
            Glovebox = { MaxWeight = 10000, MaxSlots = 4 },
            Trunk    = { MaxWeight = 12, MaxSlots = 150000 }
        },

        -- Military
        [19] = { 
            Glovebox = { MaxWeight = 0, MaxSlots = 0 },
            Trunk    = { MaxWeight = 0, MaxSlots = 0 }
        },

        -- Commercial
        [20] = { 
            Glovebox = { MaxWeight = 0, MaxSlots = 0 },
            Trunk    = { MaxWeight = 0, MaxSlots = 0 }
        },

        -- Trains
        [21] = { 
            Glovebox = { MaxWeight = 0, MaxSlots = 0 },
            Trunk    = { MaxWeight = 0, MaxSlots = 0 }
        },

        -- Commercial
        [22] = { 
            Glovebox = { MaxWeight = 0, MaxSlots = 0 },
            Trunk    = { MaxWeight = 0, MaxSlots = 0 }
        },
    },

    -- Overrides storage for a specific vehicle model
    ModelOverrides = {

        -- Example of weight and slot overrides for vehicle
        ['police'] = {
            Glovebox = { MaxWeight = 80000, MaxSlots = 15 },
            Trunk    = { MaxWeight = 200000, MaxSlots = 50 }
        }
    },

    -- Defines which vehicles have a trunk in the front
    BackEngine = {
        ['ninef'] = true,
        ['adder'] = true,
        ['vagner'] = true,
        ['t20'] = true,
        ['infernus'] = true,
        ['zentorno'] = true,
        ['reaper'] = true,
        ['comet2'] = true,
        ['comet3'] = true,
        ['jester'] = true,
        ['jester2'] = true,
        ['cheetah'] = true,
        ['cheetah2'] = true,
        ['prototipo'] = true,
        ['turismor'] = true,
        ['pfister811'] = true,
        ['ardent'] = true,
        ['nero'] = true,
        ['nero2'] = true,
        ['tempesta'] = true,
        ['vacca'] = true,
        ['bullet'] = true,
        ['osiris'] = true,
        ['entityxf'] = true,
        ['turismo2'] = true,
        ['fmj'] = true,
        ['re7b'] = true,
        ['tyrus'] = true,
        ['italigtb'] = true,
        ['penetrator'] = true,
        ['monroe'] = true,
        ['ninef2'] = true,
        ['stingergt'] = true,
        ['surfer'] = true,
        ['surfer2'] = true,
        ['gp1'] = true,
        ['autarch'] = true,
        ['tyrant'] = true
    }
}