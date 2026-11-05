return function(core)
    local Section = core.Section
    local player = game:GetService("Players").LocalPlayer
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")

    local state = {
        speed = false, speedVal = 32,
        jump = false, jumpVal = 50,
        gravity = false, gravityVal = 196.2,
        hip = false, hipVal = 2,
        god = false, anchor = false, invis = false, fullbright = false
    }

    local defaultGravity = Workspace.Gravity

    local function getHum()
        local c = player.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function getRoot()
        local c = player.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    Section:Toggle({
        Title = "WalkSpeed",
        Desc = "Change your character's speed",
        Value = false,
        Callback = function(v) state.speed = v end,
    })
    Section:Slider({
        Title = "Speed Value",
        Step = 1,
        Value = { Min = 16, Max = 300, Default = 32 },
        Callback = function(v) state.speedVal = v end,
    })

    Section:Toggle({
        Title = "JumpPower",
        Desc = "Change your jump height",
        Value = false,
        Callback = function(v) state.jump = v end,
    })
    Section:Slider({
        Title = "Jump Value",
        Step = 1,
        Value = { Min = 50, Max = 500, Default = 50 },
        Callback = function(v) state.jumpVal = v end,
    })

    Section:Toggle({
        Title = "Gravity",
        Desc = "Change world gravity",
        Value = false,
        Callback = function(v) state.gravity = v end,
    })
    Section:Slider({
        Title = "Gravity Value",
        Step = 1,
        Value = { Min = 0, Max = 500, Default = 196 },
        Callback = function(v) state.gravityVal = v end,
    })

    Section:Toggle({
        Title = "HipHeight",
        Desc = "Change your character's height off the ground",
        Value = false,
        Callback = function(v) state.hip = v end,
    })
    Section:Slider({
        Title = "HipHeight Value",
        Step = 0.1,
        Value = { Min = -5, Max = 20, Default = 2 },
        Callback = function(v) state.hipVal = v end,
    })

    Section:Toggle({
        Title = "God Mode",
        Desc = "Prevents you from taking damage",
        Value = false,
        Callback = function(v)
            state.god = v
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

    Section:Toggle({
        Title = "Anchor",
        Desc = "Freezes you completely in place",
        Value = false,
        Callback = function(v)
            state.anchor = v
            local root = getRoot()
            if root then root.Anchored = v end
        end,
    })

    Section:Toggle({
        Title = "Invisible",
        Desc = "Makes your character invisible",
        Value = false,
        Callback = function(v)
            state.invis = v
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

    Section:Toggle({
        Title = "Fullbright",
        Desc = "Removes shadows and boosts lighting",
        Value = false,
        Callback = function(v)
            state.fullbright = v
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

    Section:Button({
        Title = "Reset Character",
        Icon = "rotate-ccw",
        Callback = function()
            local hum = getHum()
            if hum then hum.Health = 0 end
        end,
    })

    RunService.Heartbeat:Connect(function()
        local hum = getHum()
        if not hum then return end

        if state.speed then hum.WalkSpeed = state.speedVal else hum.WalkSpeed = 16 end
        if state.jump then hum.UseJumpPower = true hum.JumpPower = state.jumpVal else hum.JumpPower = 50 end
        if state.hip then hum.HipHeight = state.hipVal end
        if state.gravity then Workspace.Gravity = state.gravityVal else Workspace.Gravity = defaultGravity end
        if state.god then hum.MaxHealth = math.huge hum.Health = math.huge end
    end)

    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if state.anchor then
            local r = char:WaitForChild("HumanoidRootPart", 3)
            if r then r.Anchored = true end
        end
        if state.invis then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                end
            end
        end
    end)
end
