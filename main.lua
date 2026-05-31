local prescript = require("prescript")
local socket = require("socket")

-- Constants
local TYPE_SPEED = 45
local DECODE_SPEED = 30
local SCRAMBLE_SPEED = 0.025
local FONT = nil
local CHARACTER_SET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"

-- Variables
local prescriptData = {
    visibleCharacters = 0,
    decodedCharacters = 0,
    scrambleTimer = 0,
    decodeTimer = 0,
    timer = 0,

    typingFinishedPlaying = false,
    typingStarted = false,

    scrambleText = "",
    phase = "finished",
    text = "",
}

local function playFinishedSequence(count)
    if count <= 0 then 
        return 
    end

    local newAudio = love.audio.newSource("assets/audio/Typing Finished.wav", "static")
    newAudio:play()

    newAudio:after(newAudio:getDuration(), function()
        playFinishedSequence(count - 1)
    end)
end

local function drawGlowChar(char, x, y, r, g, b)
    -- crisp outline (unchanged)
    love.graphics.setColor(0, 0, 0, 0.9)

    love.graphics.print(char, x - 1, y)
    love.graphics.print(char, x + 1, y)
    love.graphics.print(char, x, y - 1)
    love.graphics.print(char, x, y + 1)

    love.graphics.print(char, x - 1, y - 1)
    love.graphics.print(char, x + 1, y - 1)
    love.graphics.print(char, x - 1, y + 1)
    love.graphics.print(char, x + 1, y + 1)

    -- smaller, tighter glow
    love.graphics.setColor(r, g, b, 0.14)

    love.graphics.print(char, x - 2, y)
    love.graphics.print(char, x + 2, y)
    love.graphics.print(char, x, y - 2)
    love.graphics.print(char, x, y + 2)

    -- core text (sharp)
    love.graphics.setColor(r, g, b, 1)
    love.graphics.print(char, x, y)
end

local function randomCharacter()
    local index = math.random(1, #CHARACTER_SET)
    return string.sub(CHARACTER_SET, index, index)
end

local function updateScrambleText()
    local result = ""

    for i = 1, prescriptData.visibleCharacters do
        local actual = string.sub(prescriptData.text, i, i)

        if i <= prescriptData.decodedCharacters then
            result = result .. actual

        elseif actual == " " then
            result = result .. " "

        else
            result = result .. randomCharacter()
        end
    end

    prescriptData.scrambleText = result
end

local function getDisplayText()
    local result = ""

    for i = 1, prescriptData.visibleCharacters do
        local actual =
            string.sub(prescriptData.text, i, i)

        if i <= prescriptData.decodedCharacters then
            result = result .. actual

        elseif actual == " " then
            result = result .. " "

        else
            result = result .. randomCharacter()
        end
    end

    return result
end

local function runPrescript()
    prescriptData.visibleCharacters = 0
    prescriptData.decodedCharacters = 0
    prescriptData.scrambleTimer = 0
    prescriptData.decodeTimer = 0
    prescriptData.timer = 0

    prescriptData.typingFinishedPlaying = false
    prescriptData.typingStarted = false

    prescriptData.scrambleText = ""
    prescriptData.phase = "typing"
    prescriptData.text = prescript.createPrescript()
end

function love.load()
    love.window.setMode(0, 0, {
        fullscreen = true,
        fullscreentype = "desktop",
        resizable = false,
        vsync = 1,
        msaa = 0
    })

    FONT = love.graphics.newFont(
        "assets/fonts/PixelifySans-VariableFont_wght.ttf",
        24
    )

    love.graphics.setColor(0.604, 0.839, 1, 1)
    love.graphics.setFont(FONT)
end

function love.update(dt)
  prescriptData.scrambleTimer =
        prescriptData.scrambleTimer + dt

    if prescriptData.scrambleTimer >= SCRAMBLE_SPEED then
        prescriptData.scrambleTimer = 0
        updateScrambleText()
    end

    if prescriptData.phase == "typing" then
        if not prescriptData.typingStarted then
            love.audio.newSource("assets/audio/Typing Audio.wav", "static"):play()
            prescriptData.typingStarted = true
        end

        prescriptData.timer = prescriptData.timer + dt

        local visible = math.floor(prescriptData.timer * TYPE_SPEED)

        if visible >= #prescriptData.text then
            visible = #prescriptData.text
            prescriptData.phase = "decoding"
        end

        prescriptData.visibleCharacters = visible

    elseif prescriptData.phase == "decoding" then
        prescriptData.decodeTimer = prescriptData.decodeTimer + dt

        local decoded = math.floor(prescriptData.decodeTimer * DECODE_SPEED)

        prescriptData.decodedCharacters = math.min(decoded, #prescriptData.text)

        if prescriptData.decodedCharacters >= #prescriptData.text then
            prescriptData.phase = "finished"

            if not prescriptData.typingFinishedPlaying then
                prescriptData.typingFinishedPlaying = true
                
                love.audio.newSource("assets/audio/Typing Finished.wav", "static"):play()
            end
        end
    end
end

function love.draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    local textHeight = FONT:getHeight()
    local lineHeight = textHeight + 6

    -- split text into two halves
    local text = prescriptData.text
    local mid = math.floor(#text / 2)

    -- find a better break point (optional: break at space)
    for i = mid, 1, -1 do
        if string.sub(text, i, i) == " " then
            mid = i
            break
        end
    end

    local line1 = string.sub(text, 1, mid)
    local line2 = string.sub(text, mid + 1)

    local function drawLine(line, scrambleStartIndex, y)
       local positions = {}
    local totalWidth = 0

    for i = 1, #line do
        local char = string.sub(line, i, i)
        positions[i] = totalWidth
        totalWidth = totalWidth + FONT:getWidth(char)
    end

    local startX = (width - totalWidth) / 2

    for i = 1, #line do
        local globalIndex = scrambleStartIndex + (i - 1)

        local character =
            string.sub(prescriptData.scrambleText, globalIndex, globalIndex)

        drawGlowChar(
            character,
            startX + positions[i],
            y,
            0.604,
            0.839,
            1
        )
    end
    end

    local centerY = height / 2 - lineHeight / 2

    drawLine(line1, 1, centerY)
    drawLine(line2, #line1 + 1, centerY + lineHeight)
end

function love.mousepressed(x, y, button)
    if button == 1 and prescriptData.phase == "finished" then
        runPrescript()
    end
end
