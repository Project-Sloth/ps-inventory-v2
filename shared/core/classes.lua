if not Core then Core = {} end

-- Creates empty table to hold classes
Core.Classes = {
    
    -- Registers a new class
    ---@param ClassName string
    ---@param InitialState? table
    New = function (ClassName, InitialState)

        -- Checks for class existence
        if Core.Classes.Exists(ClassName) then

            Core.Utilities.Log({
                type = "error",
                title = "Class Already Exists",
                message = "[" .. ClassName .. "] has already been registered"
            })

            return false
        end

        -- Set to empty table by default
        Core.Classes[ClassName] = {}

        -- Set metatable data
        Core.Classes[ClassName] = setmetatable(Core.Classes[ClassName], {
            __index = Core.Classes.DefaultClassMethods
        })
    
        -- Call the constructor with the initial state
        Core.Classes[ClassName]:Constructor(InitialState or {})

        -- Debug print
        Core.Utilities.Log({
            title = "Class Registered",
            message = "[" .. ClassName .. "] has been registered"
        })
    end,

    -- Checks if a class exists
    ---@param ClassName string
    Exists = function (ClassName)
        if Core.Classes[ClassName] then return true end
        return false
    end,

    -- Default methods to initialize class with
    DefaultClassMethods = {

        -- Sets initial state
        ---@param self table
        ---@param state table
        Constructor = function(self, state)
            if state then self.state = state end
            return self
        end,

        -- Gets the state of the class
        ---@param self table
        ---@param key string
        GetState = function (self, key)
            if not key then return self.state end
            if not self.state[key] then return nil end
            return self.state[key]
        end,
        
        -- Updates the state of the class
        ---@param self table
        ---@param key string|table
        ---@param value? any
        ---@param cb? function
        UpdateState = function (self, key, value, cb)
            if type(key) == "table" then
                for k, v in pairs(key) do
                    self.state[k] = v
                end
            else
                self.state[key] = value
            end
            
            if not cb then return self.state[key] end
            if type(cb) == "function" then cb(self.state[key]) end
        end
    },
}