local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Blame",
    Folder = "Blame",
    Size = UDim2.fromOffset(600, 480),
})

local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })
HomeTab:Paragraph({
    Title = "Blame Test",
    Desc = "If you see this, the main script loaded!",
})

-- Create the tabs here FIRST
local CharacterTab = Window:Tab({ Title = "Character", Icon = "user" })
local MovementTab = Window:Tab({ Title = "Movement", Icon = "move" })

local CacheBust = "?t=" .. tostring(os.time())
local BaseUrl = "https://raw.githubusercontent.com/yoomoonlol/blame/main/Modules/"

local function loadModule(name, tab)
    local code = game:HttpGet(BaseUrl .. name .. ".lua" .. CacheBust)
    local fn = loadstring(code)
    if fn then
        -- Pass the created tab into the module
        pcall(fn, { Window = Window, Tab = tab })
    end
end

loadModule("Character", CharacterTab)
loadModule("Movement", MovementTab)

WindUI:Notify({ Title = "Blame", Content = "Loaded successfully!", Duration = 5 })
