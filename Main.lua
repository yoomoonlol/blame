-- Save WindUI and Window to the global executor environment
getgenv().WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

getgenv().BlameWindow = getgenv().WindUI:CreateWindow({
    Title = "Blame",
    Folder = "Blame",
    Size = UDim2.fromOffset(600, 480),
})

local Window = getgenv().BlameWindow

local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })
HomeTab:Paragraph({
    Title = "Blame Test",
    Desc = "If you see this, the main script loaded!",
})

-- The Cache Buster
local CacheBust = "?t=" .. tostring(os.time())
local BaseUrl = "https://raw.githubusercontent.com/yoomoonlol/blame/main/Modules/"

local function loadModule(name)
    local code = game:HttpGet(BaseUrl .. name .. ".lua" .. CacheBust)
    local fn = loadstring(code)
    if fn then
        pcall(fn)
    end
end

loadModule("Character")
loadModule("Movement")

getgenv().WindUI:Notify({ Title = "Blame", Content = "Loaded successfully!", Duration = 5 })
