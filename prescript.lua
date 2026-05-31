local data = require("data")
local utils = require("utils")
local config = require("config")

local functions = {
    option = {
        duration = function(optionData, prescript, blacklist)
            local min = optionData.min or 1
            local max = optionData.max or 2
            local time = math.random(min, max)
            local formattedTime = utils.timeFormatter(time)
            local text = formattedTime

            return text
        end,

        event = function(optionData, prescript, blacklist)
            local selectedEvent = nil
            if optionData.whitelist then
                local eventCount = #optionData.whitelist
                local randomEvent = math.random(1, eventCount)

                selectedEvent = optionData.whitelist[randomEvent]
            else
                local eventTable = utils.filterDictionary(utils.filterDictionary(data.events, blacklist), optionData.blacklist)
                local eventCount = utils.getDictionarySize(eventTable)
                local randomEvent = math.random(1, eventCount)

                local count = 0
                for index in pairs(eventTable) do
                    count = count + 1
                    if count == randomEvent then
                        selectedEvent = index
                        break
                    end
                end
            end

            local specificData = data.events[selectedEvent]
            local text = specificData.text

            table.insert(blacklist, selectedEvent)

            return text
        end,

        blank = function(optionData, prescript, blacklist)
            local text = ""

            return text
        end,

        location = function(optionData, prescript, blacklist)
            local selectedLocation = nil
            if optionData.whitelist then
                local eventCount = #optionData.whitelist
                local randomLocation = math.random(1, eventCount)

                selectedLocation = optionData.whitelist[randomLocation]
            else
                local locationTable = utils.filterDictionary(utils.filterDictionary(data.locations, blacklist), optionData.blacklist)
                local eventCount = utils.getDictionarySize(locationTable)
                local randomLocation = math.random(1, eventCount)

                local count = 0
                for index in pairs(locationTable) do
                    count = count + 1
                    if count == randomLocation then
                        selectedLocation = index
                        break
                    end
                end
            end

            local specificData = data.locations[selectedLocation]
            local text = specificData.text

            table.insert(blacklist, selectedLocation)

            return text
        end
    },

    modifier = {
        liquid = function(modifierData, prescript, blacklist)
            local liquidTable = utils.filterTable(data.liquids, blacklist)
            local randomLiquid = liquidTable[math.random(1, #liquidTable)]
            local text = randomLiquid

            table.insert(blacklist, randomLiquid)

            return text
        end,

        oz = function(modifierData, prescript, blacklist)
            local randomAmount = math.random(modifierData.min, modifierData.max)
            local text = randomAmount.. "oz"

            return text
        end,

        person = function(modifierData, prescript, blacklist)

        end,

        blank = function(modifierData, prescript, blacklist)
            local text = ""

            return text
        end,

        location = function(modifierData, prescript, blacklist)
            local selectedLocation = nil
            if modifierData.whitelist then
                local eventCount = #modifierData.whitelist
                local randomLocation = math.random(1, eventCount)

                selectedLocation = modifierData.whitelist[randomLocation]
            else
                local locationTable = utils.filterDictionary(utils.filterDictionary(data.locations, blacklist), modifierData.blacklist)
                local eventCount = utils.getDictionarySize(locationTable)
                local randomLocation = math.random(1, eventCount)

                local count = 0
                for index in pairs(locationTable) do
                    count = count + 1
                    if count == randomLocation then
                        selectedLocation = index
                        break
                    end
                end
            end

            local specificData = data.locations[selectedLocation]
            local text = specificData.text

            table.insert(blacklist, selectedLocation)

            return text
        end
    }
}

local function runFunction(functionType, functionName, data, prescript, blacklist)
    local hasDeterminer = utils.hasDeterminer(prescript)

    if data.avoidDeterminer then
        if hasDeterminer then
            return nil
        end
    end

    local text = functions[functionType][functionName](data, prescript, blacklist)
    if data.determinerPrefix and hasDeterminer then
        text = data.determinerPrefix.. text
    elseif data.prefix then
        text = data.prefix.. text
    end

    if data.determinerSuffix and hasDeterminer then
        text = text.. data.determinerSuffix
    elseif data.suffix then
        text = text.. data.suffix
    end

    return text
end

local function generateIntro(blacklist)
    local intros = utils.filterDictionary(data.intros, blacklist)
    local dictionarySize = utils.getDictionarySize(intros)
    local randomValue = math.random(1, dictionarySize)
    local selectedIntro = nil
    local count = 0
    for index in pairs(data.intros) do
        count = count + 1

        if count == randomValue then
            selectedIntro = index
            break
        end
    end

    return selectedIntro
end

local function generateOption(optionTable, blacklist)
    local optionTable = utils.filterTable(optionTable, blacklist)
    local tableSize = #optionTable
    if tableSize <= 0 then
        return
    end

    local randomOption = math.random(1, tableSize)
    return optionTable[randomOption]
end

local function generateAction(prescript, blacklist)
    local hasDeterminer = utils.hasDeterminer(prescript)
    local actions = utils.filterDictionary(data.actions, blacklist, hasDeterminer)
    local dictionarySize = utils.getDictionarySize(actions)
    local randomValue = math.random(1, dictionarySize)
    local selectedAction = nil
    local count = 0
    for index in pairs(actions) do
        count = count + 1

        if count == randomValue then
            selectedAction = index
            break
        end
    end

    return selectedAction
end

local function generateExtension()
    local dictionarySize = utils.getDictionarySize(data.extensions)
    local randomValue = math.random(1, dictionarySize)
    local selectedExtension = nil
    local count = 0
    for index in pairs(data.extensions) do
        count = count + 1

        if count == randomValue then
            selectedExtension = index
            break
        end
    end

    return selectedExtension
end

local function generateFullIntro(prescript, prescriptRepeatBlacklist)
    local intro = generateIntro(prescriptRepeatBlacklist)
    local introData = nil
    if intro then
        introData = data.intros[intro]
        table.insert(prescriptRepeatBlacklist, intro)

        prescript = prescript.. introData.text
    end

    if introData and introData.options then
        local option = generateOption(introData.options, prescriptRepeatBlacklist)
        if option then
            local optionResult = runFunction("option", option.name, option, prescript, prescriptRepeatBlacklist)
            prescript = prescript.. optionResult.. ", "
        end
    end
    
    return prescript, prescriptRepeatBlacklist
end

local function generateFullAction(prescript, prescriptRepeatBlacklist)
    local action = generateAction(prescript, prescriptRepeatBlacklist)
    local actionData = nil
    if action then
        actionData = data.actions[action]
        table.insert(prescriptRepeatBlacklist, action)

        prescript = prescript.. actionData.text
    end

    if actionData and actionData.modifiers then
        local randomModifer = math.random(1, #actionData.modifiers)
        for i, modiferTable in pairs(actionData.modifiers) do
            if modiferTable.required and randomModifer == i then
                randomModifer = randomModifer + 1
            end

            if modiferTable.required or randomModifer == i then
                local modiferResult = runFunction("modifier", modiferTable.name, modiferTable, prescript, prescriptRepeatBlacklist)
                if modiferResult then
                    prescript = prescript.. modiferResult.. " "
                end
            end
        end
    end

    if actionData and actionData.options then
        local option = generateOption(actionData.options, prescriptRepeatBlacklist)
        if option then
            local optionResult = runFunction("option", option.name, option, prescript, prescriptRepeatBlacklist)
            prescript = prescript.. optionResult
        end
    end

    return prescript, prescriptRepeatBlacklist
end

local function generateFullExtension(prescript, prescriptRepeatBlacklist)
    local extensionChance = math.random(1, config.EXTENSION_CHANCE)
    if extensionChance ~= config.EXTENSION_CHANCE then
        return prescript, prescriptRepeatBlacklist
    end

    -- Makes sure there isn't a lingering space from modifiers. I could probably write a way better way to avoid that. I don't care.
    if string.sub(prescript, #prescript, -1) == " " then
        prescript = string.sub(prescript, 1, -2)
    end

    local extension = generateExtension()
    local extensionData = nil
    if extension then
        extensionData = data.extensions[extension]
        prescript = prescript.. extensionData.text
    end

    if extensionData and extensionData.options then
        local option = generateOption(extensionData.options, prescriptRepeatBlacklist)
        if option then
            local optionResult = runFunction("option", option.name, option, prescript, prescriptRepeatBlacklist)
            -- It's 2am and I'm just going to hardcode fix things now :3
            if optionResult ~= "" then 
                prescript = prescript.. optionResult.. " "
            end
        end
    end

    prescript, prescriptRepeatBlacklist = generateFullAction(prescript, prescriptRepeatBlacklist)
    prescript, prescriptRepeatBlacklist = generateFullExtension(prescript, prescriptRepeatBlacklist)

    return prescript, prescriptRepeatBlacklist
end

local function createPrescript()
    local prescript = ""
    local prescriptRepeatBlacklist = {}

    prescript, prescriptRepeatBlacklist = generateFullIntro(prescript, prescriptRepeatBlacklist)
    prescript, prescriptRepeatBlacklist = generateFullAction(prescript, prescriptRepeatBlacklist)
    prescript, prescriptRepeatBlacklist = generateFullExtension(prescript, prescriptRepeatBlacklist)

    -- Makes sure there isn't a lingering space from modifiers. I could probably write a way better way to avoid that. I don't care.
    if string.sub(prescript, #prescript, -1) == " " then
        prescript = string.sub(prescript, 1, -2)
    end

    prescript = "_".. prescript.. "_"

    return prescript
end

for i = 1, 50 do
    createPrescript()
end

return {
    createPrescript = createPrescript
}