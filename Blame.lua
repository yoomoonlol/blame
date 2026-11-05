-- Blame Hub | Native + IY Backend
-- UI: WindUI | Native Logic: Blame | Fallback: Infinite Yield

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local IY_URL = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

--// Window Setup
local Window = WindUI:CreateWindow({
    Title = "Blame",
    Folder = "Blame",
    Size = UDim2.fromOffset(680, 520),
    Icon = "snowflake",
})

--// Tags (Using the Tag API from your docs link)
Window:Tag({
    Title = "v1.0.0",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 4,
})
Window:Tag({
    Title = "Native",
    Icon = "zap",
    Color = Color3.fromHex("#ffb02e"),
    Radius = 4,
})

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

-- IY Backend Setup
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
    Desc = "Native commands + IY fallback for full coverage.",
    Image = "snowflake",
})

----------------------------------------------------------------
-- CHARACTER TAB
----------------------------------------------------------------
local CharacterTab = Window:Tab({ Title = "Character", Icon = "user" })
local CharSec = CharacterTab:Section({ Title = "Stats", Box = true, Opened = true })

local charState = {
    speed = false, speedVal = 32,
    jump = false, jumpVal = 50,
    gravity = false, gravityVal = 196.2,
    god = false, anchor = false, invis = false, fullbright = false
}
local defaultGravity = Workspace.Gravity

CharSec:Toggle({
    Title = "WalkSpeed",
    Desc = "Change your character's speed",
    Value = false,
    Callback = function(v) charState.speed = v end,
})
CharSec:Slider({
    Title = "Speed Value",
    Step = 1,
    Value = { Min = 16, Max = 300, Default = 32 },
    Callback = function(v) charState.speedVal = v end,
})

CharSec:Toggle({
    Title = "JumpPower",
    Desc = "Change your jump height",
    Value = false,
    Callback = function(v) charState.jump = v end,
})
CharSec:Slider({
    Title = "Jump Value",
    Step = 1,
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(v) charState.jumpVal = v end,
})

CharSec:Toggle({
    Title = "Gravity",
    Desc = "Change world gravity",
    Value = false,
    Callback = function(v) charState.gravity = v end,
})
CharSec:Slider({
    Title = "Gravity Value",
    Step = 1,
    Value = { Min = 0, Max = 500, Default = 196 },
    Callback = function(v) charState.gravityVal = v end,
})

CharSec:Toggle({
    Title = "God Mode",
    Desc = "Prevents you from taking damage",
    Value = false,
    Callback = function(v)
        charState.god = v
        local hum = getHum()
        if hum then
            if v then hum.MaxHealth = math.huge hum.Health = math.huge
            else hum.MaxHealth = 100 hum.Health = 100 end
        end
    end,
})

CharSec:Toggle({
    Title = "Anchor",
    Desc = "Freezes you completely in place",
    Value = false,
    Callback = function(v)
        charState.anchor = v
        local root = getRoot()
        if root then root.Anchored = v end
    end,
})

CharSec:Toggle({
    Title = "Invisible",
    Desc = "Makes your character invisible",
    Value = false,
    Callback = function(v)
        charState.invis = v
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = v and 1 or 0
                end
            end
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
local MoveSec = MoveTab:Section({ Title = "Movement Options", Box = true, Opened = true })

local moveState = {
    noclip = false,
    fly = false, flySpeed = 60,
    infJump = false
}

local noclipParts = {}
MoveSec:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(v) moveState.noclip = v end,
})

UserInputService.JumpRequest:Connect(function()
    if moveState.infJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
MoveSec:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump endlessly",
    Value = false,
    Callback = function(v) moveState.infJump = v end,
})

local flyBV, flyBG
MoveSec:Toggle({
    Title = "Fly",
    Desc = "WASD to move, Space/Ctrl for up/down",
    Value = false,
    Callback = function(v)
        moveState.fly = v
        if v then
            local hum, root = getHum(), getRoot()
            if hum and root then
                hum.PlatformStand = true
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBV.Parent = root
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                flyBG.P = 9e4
                flyBG.Parent = root
            end
        else
            if flyBV then flyBV:Destroy() flyBV = nil end
            if flyBG then flyBG:Destroy() flyBG = nil end
            local hum = getHum()
            if hum then hum.PlatformStand = false end
        end
    end,
})
MoveSec:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = { Min = 10, Max = 200, Default = 60 },
    Callback = function(v) moveState.flySpeed = v end,
})

----------------------------------------------------------------
-- TELEPORT TAB
----------------------------------------------------------------
local TpTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TpSec = TpTab:Section({ Title = "Teleport Options", Box = true, Opened = true })

TpSec:Button({
    Title = "Teleport to Camera",
    Callback = function()
        local root = getRoot()
        if root then root.CFrame = Workspace.CurrentCamera.CFrame end
    end,
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

TpSec:Button({
    Title = "Rejoin Server",
    Callback = function() TeleportService:Teleport(game.PlaceId, player) end,
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
-- MASTER LOOP (Native Updates)
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local hum, root = getHum(), getRoot()
    if not hum or not root then return end

    -- Character
    if charState.speed then hum.WalkSpeed = charState.speedVal else hum.WalkSpeed = 16 end
    if charState.jump then hum.UseJumpPower = true hum.JumpPower = charState.jumpVal else hum.JumpPower = 50 end
    if charState.gravity then Workspace.Gravity = charState.gravityVal else Workspace.Gravity = defaultGravity end
    if charState.god then hum.MaxHealth = math.huge hum.Health = math.huge end

    -- Noclip
    if moveState.noclip then
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
    if moveState.fly and flyBV and flyBG then
        if flyBV.Parent ~= root then
            flyBV.Parent = root
            flyBG.Parent = root
        end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end

        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * moveState.flySpeed or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end
end)

-- Handle Respawn
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if charState.anchor then
        local r = char:WaitForChild("HumanoidRootPart", 3)
        if r then r.Anchored = true end
    end
    if charState.invis then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            end
        end
    end
end)

-- Background IY Load (for Search All)
task.spawn(function() pcall(function() loadstring(game:HttpGet(IY_URL))() end) end)

WindUI:Notify({ Title = "Blame", Content = "Loaded Successfully!", Duration = 4 })
