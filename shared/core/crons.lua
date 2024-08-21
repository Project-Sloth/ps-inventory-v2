if not Core then Core = {} end

Core.Crons = {

    -- Whether the processor can run or not
    Enabled = true,

    -- Jobs state
    Jobs = {},

    -- Adds a cron job
    ---@param data table
    AddJob = function (data)
        local jobs = Core.Crons.Jobs
        table.insert(jobs, data)
        Core.Crons.Jobs = jobs
        return true
    end,

    -- Updates a cron job by it's id
    ---@param id string
    ---@param data table
    UpdateJob = function (id, data)
        if type(data) ~= "table" then return false end

        local exists = Core.Crons.GetJobById(id)
        if exists then
            for k, v in pairs(data) do
                Core.Crons.Jobs[exists.key][k] = v
            end

            return true
        end

        return false
    end,

    -- Removes a cron job by it's id
    ---@param id string
    RemoveJob = function (id)
        local exists = Core.Crons.GetJobById(id)
        if exists then
            local jobs = Core.Crons.Jobs
            table.remove(jobs, exists.key)
            Core.Crons.Jobs = jobs
            return true
        end

        return false
    end,

    -- Gets a cron job by it's id
    ---@param id string
    GetJobById = function (id)
        local data = nil

        for k, job in pairs(Core.Crons.Jobs) do
            if job.id == id then
                data = {
                    key = k,
                    data = job
                }
            end
        end

        return data
    end,

    -- Example: Register('test', '30s', function() end)
    ---@param id string
    ---@param recurring number|string
    ---@param func function
    ---@param logging? boolean
    Register = function (id, recurring, func, logging)

        -- Server check
        if not IsDuplicityVersion() then
            return Core.Utilities.Log({
                type = "error",
                title = "Crons.Register",
                message = "This function is server-only."
            })
        end

        if not id then return false end
        if not recurring then return false end
        if not func then return false end
        if type(func) ~= "function" then return false end

        -- Either recurring is a number (seconds) or should be converted
        recurring = tonumber(recurring) and recurring or Core.Crons.ConvertRecurring(recurring)
        if not recurring then return false end

        local exists = Core.Crons.GetJobById(id)
        if exists then return false end

        Core.Crons.AddJob({
            id = id,
            recurring = recurring,
            lastRun = os.time(),
            nextRun = (os.time() + recurring),
            logging = logging and logging or false,
            callback = function (cb)
                func()

                if type(cb) == "function" then
                    cb()
                end
            end
        })

        Core.Utilities.Log({
            title = "Core.Crons.AddJob",
            message = ("%s job has been registered and is running every %i seconds"):format(id, recurring)
        })
    end,

    -- Process a job by it's id
    ---@param id string
    Process = function (id)

        -- Server check
        if not IsDuplicityVersion() then
            return Core.Utilities.Log({
                type = "error",
                title = "Crons.Register",
                message = "This function is server-only."
            })
        end

        local job = Core.Crons.GetJobById(id)
        if not job then return false end

        job.data.callback(function()

            if job.data.logging then
                Core.Utilities.Log({
                    title = ("Cron[%s]"):format(job.data.id),
                    message = "Job has been processed"
                })
            end

            Core.Crons.UpdateJob(job.data.id, {
                lastRun = os.time(),
                nextRun = (os.time() + job.data.recurring)
            })
        end)
    end,

    -- Ends the processor loop
    EndProcessor = function ()

        -- Server check
        if not IsDuplicityVersion() then
            return Core.Utilities.Log({
                type = "error",
                title = "Crons.Register",
                message = "This function is server-only."
            })
        end

        Core.Utilities.Log({
            title = "Core.Crons",
            message = "Cron processor has been disabled"
        })

        Core.Crons.Enabled = false
    end,

    -- Starts the processor loop
    StartProcessor = function ()

        -- Server check
        if not IsDuplicityVersion() then
            return Core.Utilities.Log({
                type = "error",
                title = "Crons.Register",
                message = "This function is server-only."
            })
        end

        Core.Utilities.Log({
            title = "Core.Crons",
            message = "Cron processor has been started"
        })

        CreateThread(function ()

            while Core.Crons.Enabled do
                for _, job in pairs(Core.Crons.Jobs) do
                    if job.nextRun < os.time() or job.recurring == 1 then
                        Core.Crons.Process(job.id)
                    end
                end

                Wait(1000)
            end
        end)
    end,

    -- Converts recurring string to Seconds
    -- Example: 2m = 120seconds
    ---@param recurring string
    ConvertRecurring = function (recurring)
        if not recurring:find('s') and not recurring:find('m') and not recurring:find('h') and not recurring:find('d') then
            return nil
        end

        if recurring:find('s') then
            recurring = recurring:gsub("s", "")
            return tonumber(recurring) and tonumber(recurring) or nil
        end

        if recurring:find('m') then
            recurring = recurring:gsub("m", "")
            return tonumber(recurring) and (tonumber(recurring) * 60) or nil
        end

        if recurring:find('h') then
            recurring = recurring:gsub("h", "")
            return tonumber(recurring) and (tonumber(recurring) * 3600) or nil
        end

        if recurring:find('d') then
            recurring = recurring:gsub("d", "")
            return tonumber(recurring) and (tonumber(recurring) * 86400) or nil
        end

        return nil
    end,
}