local function getDictionarySize(dictionary)
    local count = 0

    for index in pairs(dictionary) do
        count = count + 1
    end

    return count
end

local function tableFind(tbl, value)
    for index, v in pairs(tbl) do
        if v == value or (v.name and v.name == value) then
            return index
        end
    end

    return nil
end

local function tableClone(tbl)
    local clone = {}

    for key, value in pairs(tbl) do
        clone[key] = value
    end

    return clone
end

local function clamp(value, min, max)
    if value < min then
        return min
    end

    if value > max then
        return max
    end

    return value
end

local function timeFormatter(number)
	local hours = math.floor(clamp(number / 60 / 60, 0, 999))
	local minutes = math.floor(clamp((number/60) - (hours * 60), 0, 59))
	local seconds = math.floor(clamp((number) - (hours * 60 * 60) - (minutes * 60), 0, 59))
    local formattedTime = ""
    
    if hours > 0 then
        formattedTime = formattedTime.. hours.. " hour"

        if hours > 1 then
            formattedTime = formattedTime.. "s"
        end
    end

    if minutes > 0 then
        if hours > 0 then
            formattedTime = formattedTime.. ", "
        end

       formattedTime = formattedTime.. minutes.. " minute"

        if minutes > 1 then
            formattedTime = formattedTime.. "s"
        end
    end

    if seconds > 0 then
        if hours > 0 or minutes > 0 then
            formattedTime = formattedTime.. ", and "
        end

        formattedTime = formattedTime.. seconds.. " second"

        if seconds > 1 then
            formattedTime = formattedTime.. "s"
        end
    end

    return formattedTime
end

local function split(str, separator)
    local result = {}

    for match in string.gmatch(str, "([^" .. separator .. "]+)") do
        table.insert(result, match)
    end

    return result
end

local function filterTable(tbl, blacklist)
    if not blacklist or #blacklist <= 0 then
        return tbl
    end

    local tblClone = tableClone(tbl)
    for _, item in pairs(blacklist) do
        local index = tableFind(tblClone, item)
        if index then
            table.remove(tblClone, index)
        end
    end

    return tblClone
end

local function filterDictionary(dict, blacklist, hasDeterminer)
    if not blacklist or #blacklist <= 0 then
        return dict
    end

    local dictClone = tableClone(dict)
    for _, item in pairs(blacklist) do
        dictClone[item] = nil
    end

    if hasDeterminer then
        for name, data in pairs(dictClone) do
            if data.avoidDeterminer then
                dictClone[name] = nil
            end
        end
    end

    return dictClone
end

local determiner = {
    "a",
    "an",
    "the",
    "this",
    "that",
    "these",
    "those",
}
local function hasDeterminer(text)
    local splitText = split(text, " ")
    local context 
    if #splitText > 1 then
       context = string.lower(splitText[#splitText - 1]) -- Incase the newest word, such as drink, is already here and the context has changed
    end

    local currentWord = string.lower(splitText[#splitText])
    if tableFind(determiner, context) or tableFind(determiner, currentWord) then
        return true
    end
    
    return false
end

return {
    getDictionarySize = getDictionarySize,
    filterDictionary = filterDictionary,
    hasDeterminer = hasDeterminer,
    timeFormatter = timeFormatter,
    filterTable = filterTable,
    tableClone = tableClone,
    tableFind = tableFind,
}