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

local CacheBust = "?t=" .. tostring(os.time())
local BaseUrl = "https://raw.githubusercontent.com/yoomoonlol/blame/main/Modules/"

local function loadModule(name)
    local code = game:HttpGet(BaseUrl .. name .. ".lua" .. CacheBust)
    local fn = loadstring(code)
    if not fn then
        WindUI:Notify({ Title = "Load Error", Content = "Failed to compile " .. name, Duration = 10 })
        return
    end
    
    local success, err = pcall(fn, { Window = Window })
    if not success then
        WindUI:Notify({ Title = "Module Error: " .. name, Content = tostring(err), Duration = 15 })
        warn("Module Error (" .. name .. "):", err)
    end
end

loadModule("Character")
loadModule("Movement")
