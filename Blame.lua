-- Blame Hub | Fully Native | Powered by WindUI
-- Ported logic from Roku's Multi-Feature Script (ESP/Fly/Noclip/TP)
-- UI Maxed using WindUI Docs (Sections, Dialogs, Keybinds, Configs)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

--// Window Setup
local Window = WindUI:CreateWindow({
    Title = "Blame",
    Folder = "Blame",
    Size = UDim2.fromOffset(720, 560),
    Icon = "snowflake",
    Theme = "Dark",
})

--// Tags (Maxed WindUI feature)
Window:Tag({ Title = "v2.0 Native", Icon = "zap", Color = Color3.fromHex("#30ff6a"), Radius = 4 })
Window:Tag({ Title = "WindUI Max", Icon = "layout", Color = Color3.fromHex("#ffb02e"), Radius = 4 })

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

-- Cleanup ESP when toggled off
local function clearESP()
    for _, obj in ipairs(ESPObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    ESPObjects = {}
end

----------------------------------------------------------------
-- HOME TAB
----------------------------------------------------------------
local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })
local HomeSec = HomeTab:Section({ Title = "Welcome", Box = true, Opened = true })
HomeSec:Paragraph({
    Title = "Blame Native",
    Desc = "A fully native script hub. No IY backend required.",
    Image = "snowflake",
})

HomeSec:Button({
    Title = "Show Credits",
    Icon = "info",
    Callback = function()
        WindUI:Dialog({
            Title = "Credits",
            Content = "Logic ported from open-source hubs:\n- Roku's Multi-Feature Script (ESP, Fly, Noclip)\n- Vortex Hub (ESP)\n- WindUI by Footagesus",
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

CharSec:Button({
    Title = "Reset Character",
    Icon = "rotate-ccw",
    Callback = function()
        local hum = getHum()
        if hum then hum.Health = 0 end
    end,
})

----------------------------------------------------------------
-- MOVEMENT TAB
----------------------------------------------------------------
local MoveTab = Window:Tab({ Title = "Movement", Icon = "move" })
local MoveSec = MoveTab:Section({ Title = "Movement Mods", Box = true, Opened = true })

-- Noclip (Ported from Roku)
local noclipParts = {}
MoveSec:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(v) State.Noclip = v end,
})

-- Fly (Ported from Roku using LinearVelocity)
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

-- Infinite Jump
MoveSec:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v) State.InfiniteJump = v end,
})

----------------------------------------------------------------
-- VISUALS TAB
----------------------------------------------------------------
local VisTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local VisSec = VisTab:Section({ Title = "ESP & Lighting", Box = true, Opened = true })

-- ESP (Ported from Roku/Vortex)
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
                    
                    -- Box
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = hrp
                    box.Size = Vector3.new(2, 3, 1)
                    box.Color3 = State.ESPColor
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Transparency = 0.3
                    box.Parent = game.CoreGui
                    table.insert(ESPObjects, box)

                    -- Name Tag
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

-- Click Teleport (Ported from Roku)
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

-- Config Manager (Maxed WindUI)
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
        if flyVelocity.Parent ~= root then
            flyVelocity.Parent = root
        end
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
        if target and getRoot() then
            getRoot().CFrame = target
        end
    end
end)

-- Handle Respawn
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    clearESP()
    if State.ESP then
        -- Re-enable ESP logic here if needed
    end
end)

WindUI:Notify({ Title = "Blame", Content = "Loaded Successfully!", Duration = 4 })
