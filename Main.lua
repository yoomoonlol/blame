local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Blame",
    Folder = "Blame",
    Size = UDim2.fromOffset(600, 480),
})

-- Fixed Home tab (used a Section instead of Paragraph directly on the Tab)
local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })
local HomeSec = HomeTab:Section({ Title = "Welcome", Box = true, BoxBorder = true, Opened = true })
HomeSec:Paragraph({
    Title = "Blame UI",
    Desc = "Modular rebuild in progress.",
    Image = "solar:home-bold",
})

-- Function to load modules safely
local function loadModule(name)
    local CacheBust = "?t=" .. tostring(os.time())
    local BaseUrl = "https://raw.githubusercontent.com/yoomoonlol/blame/main/Modules/"
    
    local success, code = pcall(function() return game:HttpGet(BaseUrl .. name .. ".lua" .. CacheBust) end)
    if not success then
        Window:Notify({ Title = "Download Error", Content = "Could not fetch " .. name, Duration = 5 })
        return
    end
    
    local fn, err = loadstring(code)
    if not fn then
        Window:Notify({ Title = "Compile Error", Content = name .. ": " .. tostring(err), Duration = 10 })
        return
    end
    
    local ok, runErr = pcall(fn, { Window = Window })
    if not ok then
        Window:Notify({ Title = "Module Error", Content = name .. ": " .. tostring(runErr), Duration = 10 })
    else
        Window:Notify({ Title = "Loaded", Content = name .. " module", Duration = 3 })
    end
end

-- Wait a tiny bit to let WindUI render the main window before adding tabs
task.wait(0.5)

loadModule("Character")
loadModule("Movement")
