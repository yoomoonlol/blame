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

-- We add a "?t=..." random string at the end so Roblox doesn't use the old cached file
local CacheBust = "?t=" .. tostring(os.time())
local BaseUrl = "https://raw.githubusercontent.com/yoomoonlol/blame/main/Modules/"

local charCode = game:HttpGet(BaseUrl .. "Character.lua" .. CacheBust)
local CharacterModule = loadstring(charCode)
CharacterModule({ Window = Window })

local moveCode = game:HttpGet(BaseUrl .. "Movement.lua" .. CacheBust)
local MovementModule = loadstring(moveCode)
MovementModule({ Window = Window })

WindUI:Notify({ Title = "Blame", Content = "All modules loaded!", Duration = 5 })
