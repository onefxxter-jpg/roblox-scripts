local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "Panel de Control", LoadingTitle = "Cargando...", ConfigurationSaving = {Enabled = false}, Discord = {Enabled = false}, KeySystem = false})
local Tab = Window:CreateTab("Principal", 4483362458)

local Players, UserInputService, RunService, Lighting = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local State = {Speed = 16, SpeedOn = false, JumpOn = false, InvisOn = false, EspOn = false}

task.spawn(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
    Lighting.GlobalShadows = false
    if workspace.StreamingEnabled then
        workspace.StreamingMinDistance, workspace.StreamingTargetDistance = 64, 128
    end
end)

local function getHrp() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end

RunService.RenderStepped:Connect(function()
    if State.SpeedOn then
        local hum = getHum()
        if hum and hum.WalkSpeed ~= State.Speed then hum.WalkSpeed = State.Speed end
    end
end)

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name, ScreenGui.ResetOnSpawn = "ArcoGui", false

local function buildButton(text, posY, cframe)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size, btn.Position, btn.BackgroundColor3 = UDim2.new(0, 110, 0, 38), UDim2.new(0.85, 0, posY, 0), Color3.fromRGB(25, 25, 35)
    btn.Text, btn.TextColor3, btn.TextSize, btn.Font, btn.Visible = text, Color3.fromRGB(255, 255, 255), 14, Enum.Font.Garamond, false

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color, stroke.Thickness = Color3.fromRGB(0, 150, 255), 1.5

    local dragging, dragStart, startPos
    btn.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, btn.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    btn.MouseButton1Click:Connect(function()
        local hrp = getHrp()
        if hrp then hrp.CFrame = cframe end
    end)

    return btn
end

local Arco1 = buildButton("Arco 1", 0.45, CFrame.new(-142.296478, 6.31581068, 92.6039581, -0.174470633, 0.000629922317, 0.984662175, -0.000143421159, 0.999999762, 0))
local Arco2 = buildButton("Arco 2", 0.52, CFrame.new(-298.759308, 6.32399845, 89.5742493, -0.11701639, -9.43957246e-10, 0.993129969, -4.82289808e-09, 1, 3.82225029e-10))

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        local hl = char:FindFirstChild("ESPHighlight") or Instance.new("Highlight", char)
        hl.Name, hl.FillColor, hl.FillTransparency, hl.OutlineColor, hl.DepthMode = "ESPHighlight", Color3.fromRGB(0, 150, 255), 0.3, Color3.fromRGB(255, 255, 255), Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = State.EspOn
    end
    if player.Character then setup(player.Character) end
    player.CharacterAdded:Connect(setup)
end

for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

Tab:CreateSlider({ Name = "Velocidad", Range = {0, 90}, Increment = 1, Suffix = "WalkSpeed", CurrentValue = 16, Flag = "SpeedSlider", Callback = function(val) State.Speed = val end })
Tab:CreateToggle({ Name = "Activar Velocidad", CurrentValue = false, Flag = "SpeedToggle", Callback = function(val)
    State.SpeedOn = val
    if not val then
        local hum = getHum()
        if hum then hum.WalkSpeed = 16 end
    end
end })

UserInputService.JumpRequest:Connect(function()
    if State.JumpOn then
        local hum = getHum()
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Tab:CreateToggle({ Name = "Salto Infinito", CurrentValue = false, Flag = "JumpToggle", Callback = function(val) State.JumpOn = val end })
Tab:CreateToggle({ Name = "Invisibilidad Total", CurrentValue = false, Flag = "InvisToggle", Callback = function(val)
    State.InvisOn = val
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then part.LocalTransparencyModifier = val and 1 or 0 end
        end
    end
end })

Tab:CreateToggle({ Name = "ESP Azul (Detecta Invisibles)", CurrentValue = false, Flag = "ESPToggle", Callback = function(val)
    State.EspOn = val
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("ESPHighlight")
            if hl then hl.Enabled = val end
        end
    end
end })

Tab:CreateToggle({ Name = "Mostrar Botón Arco 1", CurrentValue = false, Flag = "ArcoToggle", Callback = function(val) Arco1.Visible = val end })
Tab:CreateToggle({ Name = "Mostrar Botón Arco 2", CurrentValue = false, Flag = "Arco2Toggle", Callback = function(val) Arco2.Visible = val end })

Tab:CreateButton({ Name = "Obtener TP Tool", Callback = function()
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not bp or bp:FindFirstChild("TP Tool") then return end
    local tool = Instance.new("Tool", bp)
    tool.Name, tool.RequiresHandle = "TP Tool", false
    tool.Activated:Connect(function()
        local mouse, hrp = LocalPlayer:GetMouse(), getHrp()
        if mouse and mouse.Hit and hrp then hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end)
end })
