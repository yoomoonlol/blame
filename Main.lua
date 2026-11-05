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

local BaseUrl = "https://raw.githubusercontent.com/yoomoonlol/blame/main/Modules/"

local CharacterModule = loadstring(game:HttpGet(BaseUrl .. "Character.lua"))()
CharacterModule({ Window = Window })

local MovementModule = loadstring(game:HttpGet(BaseUrl .. "Movement.lua"))()
MovementModule({ Window = Window })

WindUI:Notify({ Title = "Blame", Content = "All modules loaded!", Duration = 5 })
