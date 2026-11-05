-- Blame Native Script (One File)
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "Blame",
    Folder = "Blame",
    Size = UDim2.fromOffset(600, 480),
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

----------------------------------------------------------------
-- HOME TAB
----------------------------------------------------------------
local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })
local HomeSec = HomeTab:Section({ Title = "Welcome", Opened = true })
HomeSec:Paragraph({
    Title = "Blame Native",
    Desc = "Select a tab on the left to get started.",
    Image = "snowflake",
})

----------------------------------------------------------------
-- CHARACTER TAB
----------------------------------------------------------------
local CharacterTab = Window:Tab({ Title = "Character", Icon = "user" })
local CharSec = CharacterTab:Section({ Title = "Stats & Actions", Opened = true })

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
            if v then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            else
                hum.MaxHealth = 100
                hum.Health = 100
            end
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
local MoveSec = MoveTab:Section({ Title = "Movement Options", Opened = true })

local moveState = {
    noclip = false,
    fly = false, flySpeed = 60,
    infJump = false
}

-- Noclip
local noclipParts = {}
MoveSec:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(v) moveState.noclip = v end,
})

-- Infinite Jump
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

-- Fly
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
local TpSec = TpTab:Section({ Title = "Teleport Options", Opened = true })

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
-- MASTER LOOP (Handles all continuous updates natively)
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local hum, root = getHum(), getRoot()
    if not hum or not root then return end

    -- Character Updates
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

WindUI:Notify({ Title = "Blame", Content = "Script Loaded!", Duration = 5 })
