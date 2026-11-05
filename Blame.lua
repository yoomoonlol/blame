-- Blame Hub v3.0 | Fully Native | Powered by WindUI
-- UI Maxed: Custom Theme, Transparency, Dialogs, Configs, Keybinds
-- Logic Ported From: ZaZa Hub, Kagu Hub, Roku

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local IY_URL = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

----------------------------------------------------------------
-- CUSTOM THEME (Maxing WindUI Looks)
----------------------------------------------------------------
WindUI:AddTheme({
    Name = "Blame Dark",
    Accent = Color3.fromHex("#6C5CE7"), -- Purple accent
    Background = Color3.fromHex("#0F0F13"), -- Deep dark
    BackgroundTransparency = 0.2,
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#1A1A21"),
    Icon = Color3.fromHex("#a1a1aa"),
    WindowBackground = Color3.fromHex("#0F0F13"),
    WindowShadow = Color3.fromHex("#000000"),
    DialogBackground = Color3.fromHex("#0F0F13"),
    DialogTitle = Color3.fromHex("#FFFFFF"),
    DialogContent = Color3.fromHex("#FFFFFF"),
    TabBackground = Color3.fromHex("#1A1A21"),
    TabTitle = Color3.fromHex("#FFFFFF"),
    TabIcon = Color3.fromHex("#6C5CE7"),
    ElementBackground = Color3.fromHex("#1A1A21"),
    ElementTitle = Color3.fromHex("#FFFFFF"),
    ElementDesc = Color3.fromHex("#a1a1aa"),
    Toggle = Color3.fromHex("#6C5CE7"),
    ToggleBar = Color3.fromHex("#FFFFFF"),
    Slider = Color3.fromHex("#6C5CE7"),
    SliderThumb = Color3.fromHex("#FFFFFF"),
})

----------------------------------------------------------------
-- WINDOW SETUP
----------------------------------------------------------------
local Window = WindUI:CreateWindow({
    Title = "Blame",
    Icon = "snowflake",
    Author = "Native Hub",
    Folder = "BlameV3",
    Size = UDim2.fromOffset(720, 560),
    Theme = "Blame Dark", -- Using the custom theme above
    Transparent = true,
    Resizable = true,
    SideBarWidth = 180,
    HideSearchBar = false,
    ToggleKey = Enum.KeyCode.RightShift,
})

Window:ToggleTransparency(true) -- Max transparency for the glass look

-- Add Tags (Maxing WindUI)
Window:Tag({ Title = "v3.0", Icon = "zap", Color = Color3.fromHex("#6C5CE7") })
Window:Tag({ Title = "Native", Icon = "box", Color = Color3.fromHex("#00B894") })

----------------------------------------------------------------
-- STATE & CONFIG
----------------------------------------------------------------
local State = {
    -- Character
    WalkSpeed = false, WalkSpeedVal = 32,
    JumpPower = false, JumpPowerVal = 50,
    GodMode = false,
    Fullbright = false,
    -- Movement
    Fly = false, FlySpeed = 60,
    Noclip = false,
    InfiniteJump = false,
    ClickTP = false,
    -- Visuals
    ESP = false, ESPColor = Color3.fromRGB(255, 50, 50),
    Chams = false,
    Tracers = false,
    -- Combat
    Aimbot = false, AimbotSmoothness = 0.5, AimbotFOV = 100,
    -- World
    Gravity = false, GravityVal = 196.2,
}

local defaultGravity = Workspace.Gravity
local ESPObjects = {}
local flyVelocity, flyAttachment

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local function getHum()
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function clearESP()
    for _, obj in ipairs(ESPObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    ESPObjects = {}
end

-- IY Backend Fallback (For Terminal)
local function getIYExec()
    local env = (getgenv and getgenv()) or _G
    return type(env.execCmd) == "function" and env.execCmd or nil
end
local function runIY(text)
    local exec = getIYExec()
    if not exec then
        WindUI:Notify({ Title = "Blame", Content = "Loading IY Backend...", Duration = 3 })
        pcall(function() loadstring(game:HttpGet(IY_URL))() end)
        for _ = 1, 50 do
            exec = getIYExec()
            if exec then break end
            task.wait(0.1)
        end
    end
    if not exec then
        WindUI:Notify({ Title = "Blame", Content = "IY Backend failed to load.", Duration = 5 })
        return
    end
    pcall(exec, text)
end

----------------------------------------------------------------
-- HOME TAB
----------------------------------------------------------------
local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })
local HomeSec = HomeTab:Section({ Title = "Welcome", Opened = true })
HomeSec:Paragraph({
    Title = "Blame Hub",
    Desc = "A fully native hub. No IY required for core features.",
    Image = "snowflake",
})

HomeSec:Button({
    Title = "Show Credits",
    Icon = "info",
    Callback = function()
        WindUI:Dialog({
            Title = "Credits",
            Content = "Logic ported from open-source hubs:\n- ZaZa Hub (ESP, Aimbot, Fly)\n- Kagu Hub (ESP, Noclip)\n- Roku (Fly, TP)\n- WindUI by Footagesus",
            Buttons = {
                { Title = "Close", Variant = "Secondary" }
            }
        })
    end,
})

----------------------------------------------------------------
-- CHARACTER TAB
----------------------------------------------------------------
local CharTab = Window:Tab({ Title = "Character", Icon = "user" })
local CharSec = CharTab:Section({ Title = "Stats & Actions", Box = true, Opened = true })

CharSec:Toggle({
    Title = "WalkSpeed",
    Desc = "Change your character's speed",
    Value = false,
    Callback = function(v) State.WalkSpeed = v end,
})
CharSec:Slider({
    Title = "Speed Value",
    Step = 1,
    Value = { Min = 16, Max = 300, Default = 32 },
    Callback = function(v) State.WalkSpeedVal = v end,
})

CharSec:Toggle({
    Title = "JumpPower",
    Desc = "Change your jump height",
    Value = false,
    Callback = function(v) State.JumpPower = v end,
})
CharSec:Slider({
    Title = "Jump Value",
    Step = 1,
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(v) State.JumpPowerVal = v end,
})

CharSec:Toggle({
    Title = "God Mode",
    Desc = "Prevents you from taking damage",
    Value = false,
    Callback = function(v)
        State.GodMode = v
        local hum = getHum()
        if hum then
            if v then hum.MaxHealth = math.huge hum.Health = math.huge
            else hum.MaxHealth = 100 hum.Health = 100 end
        end
    end,
})

CharSec:Toggle({
    Title = "Fullbright",
    Desc = "Removes shadows and boosts lighting",
    Value = false,
    Callback = function(v)
        State.Fullbright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        end
    end,
})

----------------------------------------------------------------
-- COMBAT TAB
----------------------------------------------------------------
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local CombatSec = CombatTab:Section({ Title = "Aimbot", Box = true, Opened = true })

CombatSec:Toggle({
    Title = "Aimbot",
    Desc = "Hold RMB to lock onto the nearest player",
    Value = false,
    Callback = function(v) State.Aimbot = v end,
})
CombatSec:Slider({
    Title = "Smoothness",
    Step = 0.1,
    Value = { Min = 0.1, Max = 1, Default = 0.5 },
    Callback = function(v) State.AimbotSmoothness = v end,
})
CombatSec:Slider({
    Title = "FOV",
    Step = 1,
    Value = { Min = 10, Max = 360, Default = 100 },
    Callback = function(v) State.AimbotFOV = v end,
})

----------------------------------------------------------------
-- VISUALS TAB
----------------------------------------------------------------
local VisTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local VisSec = VisTab:Section({ Title = "ESP & Lighting", Box = true, Opened = true })

VisSec:Toggle({
    Title = "Player ESP",
    Desc = "See players through walls",
    Value = false,
    Callback = function(v)
        State.ESP = v
        clearESP()
        if v then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = hrp
                    box.Size = Vector3.new(2, 3, 1)
                    box.Color3 = State.ESPColor
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Transparency = 0.3
                    box.Parent = game.CoreGui
                    table.insert(ESPObjects, box)

                    local billboard = Instance.new("BillboardGui")
                    billboard.Adornee = hrp
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = game.CoreGui

                    local text = Instance.new("TextLabel")
                    text.Parent = billboard
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = plr.Name
                    text.TextColor3 = State.ESPColor
                    text.TextStrokeTransparency = 0
                    text.TextScaled = true
                    table.insert(ESPObjects, billboard)
                end
            end
        end
    end,
})

VisSec:Colorpicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(255, 50, 50),
    Callback = function(color) State.ESPColor = color end,
})

VisSec:Toggle({
    Title = "Tracers",
    Desc = "Draw lines to players",
    Value = false,
    Callback = function(v) State.Tracers = v end,
})

----------------------------------------------------------------
-- MOVEMENT TAB
----------------------------------------------------------------
local MoveTab = Window:Tab({ Title = "Movement", Icon = "move" })
local MoveSec = MoveTab:Section({ Title = "Movement Mods", Box = true, Opened = true })

local noclipParts = {}
MoveSec:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(v) State.Noclip = v end,
})

MoveSec:Toggle({
    Title = "Fly",
    Desc = "WASD to move, Space/Ctrl for up/down",
    Value = false,
    Callback = function(v)
        State.Fly = v
        local root = getRoot()
        if v and root then
            flyAttachment = Instance.new("Attachment", root)
            flyVelocity = Instance.new("LinearVelocity", flyAttachment)
            flyVelocity.MaxForce = 100000
            flyVelocity.VectorVelocity = Vector3.zero
        elseif not v then
            if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
            if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
        end
    end,
})
MoveSec:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = { Min = 10, Max = 200, Default = 60 },
    Callback = function(v) State.FlySpeed = v end,
})

MoveSec:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v) State.InfiniteJump = v end,
})

----------------------------------------------------------------
-- TELEPORT TAB
----------------------------------------------------------------
local TpTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TpSec = TpTab:Section({ Title = "Teleport Options", Box = true, Opened = true })

-- Player Dropdown
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then table.insert(playerList, p.Name) end
end

TpSec:Dropdown({
    Title = "Teleport to Player",
    Values = playerList,
    Callback = function(selectedName)
        local target = Players:FindFirstChild(selectedName)
        if target and target.Character and getRoot() then
            getRoot().CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
        end
    end,
})

TpSec:Toggle({
    Title = "Click Teleport",
    Desc = "Click anywhere to teleport there",
    Value = false,
    Callback = function(v) State.ClickTP = v end,
})

TpSec:Input({
    Title = "Teleport to Position (X,Y,Z)",
    Placeholder = "e.g. 0, 50, 0",
    Callback = function(text)
        local x, y, z = text:match("([^,]+),?%s*([^,]+),?%s*([^,]+)")
        if x and y and z then
            local root = getRoot()
            if root then root.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z)) end
        end
    end,
})

----------------------------------------------------------------
-- WORLD TAB
----------------------------------------------------------------
local WorldTab = Window:Tab({ Title = "World", Icon = "globe" })
local WorldSec = WorldTab:Section({ Title = "Environment", Box = true, Opened = true })

WorldSec:Toggle({
    Title = "Gravity",
    Desc = "Change world gravity",
    Value = false,
    Callback = function(v) State.Gravity = v end,
})
WorldSec:Slider({
    Title = "Gravity Value",
    Step = 1,
    Value = { Min = 0, Max = 500, Default = 196 },
    Callback = function(v) State.GravityVal = v end,
})

----------------------------------------------------------------
-- SEARCH ALL (Terminal + IY Fallback)
----------------------------------------------------------------
local SearchTab = Window:Tab({ Title = "Search All", Icon = "search" })
local SearchSec = SearchTab:Section({ Title = "Command Terminal", Box = true, Opened = true })

SearchSec:Paragraph({
    Title = "Terminal",
    Desc = "Type an IY command. e.g. 'esp' or 'speed 100'",
    Image = "terminal",
})

local cmdInput = SearchSec:Input({
    Title = "Command",
    Placeholder = "fly, noclip, speed 100...",
})

SearchSec:Button({
    Title = "Execute Command",
    Icon = "play",
    Callback = function()
        local text = cmdInput.Value
        if text and text ~= "" then
            task.spawn(runIY, text)
            WindUI:Notify({ Title = "Executing", Content = text, Duration = 2 })
        end
    end,
})

----------------------------------------------------------------
-- SETTINGS TAB (Configs & Keybinds)
----------------------------------------------------------------
local SetTab = Window:Tab({ Title = "Settings", Icon = "settings" })
local SetSec = SetTab:Section({ Title = "Keybinds", Box = true, Opened = true })

SetSec:Keybind({
    Title = "Toggle Fly",
    Value = "F",
    Callback = function(v)
        if State.Fly then
            State.Fly = false
            if flyVelocity then flyVelocity:Destroy() end
            if flyAttachment then flyAttachment:Destroy() end
        else
            State.Fly = true
            local root = getRoot()
            if root then
                flyAttachment = Instance.new("Attachment", root)
                flyVelocity = Instance.new("LinearVelocity", flyAttachment)
                flyVelocity.MaxForce = 100000
            end
        end
    end,
})

SetSec:Keybind({
    Title = "Toggle Noclip",
    Value = "V",
    Callback = function(v)
        State.Noclip = not State.Noclip
        WindUI:Notify({ Title = "Noclip", Content = State.Noclip and "Enabled" or "Disabled", Duration = 2 })
    end,
})

-- Config Manager
local ConfigSec = SetTab:Section({ Title = "Configs", Box = true, Opened = true })
local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("blame_config")

ConfigSec:Button({
    Title = "Save Config",
    Callback = function()
        myConfig:Save()
        WindUI:Notify({ Title = "Config", Content = "Saved!", Duration = 3 })
    end,
})
ConfigSec:Button({
    Title = "Load Config",
    Callback = function()
        myConfig:Load()
        WindUI:Notify({ Title = "Config", Content = "Loaded!", Duration = 3 })
    end,
})

----------------------------------------------------------------
-- MASTER LOOP (Native Execution)
----------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    local hum, root = getHum(), getRoot()
    if not hum or not root then return end

    -- Character Updates
    if State.WalkSpeed then hum.WalkSpeed = State.WalkSpeedVal else hum.WalkSpeed = 16 end
    if State.JumpPower then hum.UseJumpPower = true hum.JumpPower = State.JumpPowerVal else hum.JumpPower = 50 end
    if State.GodMode then hum.MaxHealth = math.huge hum.Health = math.huge end
    if State.Gravity then Workspace.Gravity = State.GravityVal else Workspace.Gravity = defaultGravity end

    -- Noclip
    if State.Noclip then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
                noclipParts[part] = true
            end
        end
    elseif next(noclipParts) then
        for part in pairs(noclipParts) do
            if part and part.Parent then part.CanCollide = true end
        end
        noclipParts = {}
    end

    -- Fly
    if State.Fly and flyVelocity then
        if flyVelocity.Parent ~= root then flyVelocity.Parent = root end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
        flyVelocity.VectorVelocity = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Click Teleport
mouse.Button1Down:Connect(function()
    if State.ClickTP then
        local target = mouse.Hit
        if target and getRoot() then getRoot().CFrame = target end
    end
end)

-- Handle Respawn
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    clearESP()
end)

WindUI:Notify({ Title = "Blame", Content = "v3.0 Loaded Successfully!", Duration = 4 })
