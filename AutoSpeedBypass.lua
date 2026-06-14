-- Nebula Otomatik Speed Bypass (70+ Hızı)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isSpeedEnabled = true -- Başlangıçta açık
local autoSpeedBypass = 70 -- Otomatik bypass hızı
local speedNormal = 60 -- Normal hız
local speedCarry = 30 -- Taşıma hızı
local lerpAlpha = 0.35 -- Lerp değeri (yüksek PC'ler için)

local speedMultiplier = 1 -- PC performansına göre dinamik çarpan
local pcPerformanceMode = "high" -- "low", "medium", "high"

-- PC Performansını Tespit Et
local function detectPCPerformance()
    local fps = 1 / (RunService.Heartbeat:Wait() or 0.016)
    
    if fps >= 120 then
        pcPerformanceMode = "high"
        speedMultiplier = 1.3 -- Yüksek PC'ler için daha hızlı
        autoSpeedBypass = 85
    elseif fps >= 60 then
        pcPerformanceMode = "medium"
        speedMultiplier = 1.0
        autoSpeedBypass = 70
    else
        pcPerformanceMode = "low"
        speedMultiplier = 0.8
        autoSpeedBypass = 55
    end
    
    print("PC Modu: " .. pcPerformanceMode .. " | Bypass Hızı: " .. autoSpeedBypass)
end

-- İlk kez PC performansını tespit et
task.delay(1, detectPCPerformance)

-- Tuş Kontrolü
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        isSpeedEnabled = not isSpeedEnabled
        print(isSpeedEnabled and "Speed: ON ✓" or "Speed: OFF ✗")
    elseif input.KeyCode == Enum.KeyCode.X then
        isSpeedEnabled = false
    end
end)

-- Ana Speed Loop
RunService.Heartbeat:Connect(function()
    if not isSpeedEnabled or not player.Character then return end

    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local walkSpeed = hum.WalkSpeed
    
    -- Hız modunu belirle
    local targetSpeed
    if walkSpeed <= 20.4 then
        targetSpeed = speedCarry * speedMultiplier -- Taşıma hızı
    elseif walkSpeed > 20.4 and walkSpeed <= 32 then
        targetSpeed = speedCarry * speedMultiplier
    else
        targetSpeed = autoSpeedBypass -- Bypass hızı kullan
    end
    
    -- Hareket yönünü hesapla
    local moveDir = hum.MoveDirection
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    else
        moveDir = Vector3.new(0, 0, 0)
    end

    -- Velocity hesapla
    local vel = hrp.Velocity
    local desiredVel = Vector3.new(moveDir.X * targetSpeed, vel.Y, moveDir.Z * targetSpeed)
    
    -- Smooth lerp
    local newX = vel.X + (desiredVel.X - vel.X) * lerpAlpha
    local newZ = vel.Z + (desiredVel.Z - vel.Z) * lerpAlpha
    
    -- Apply velocity
    hrp.Velocity = Vector3.new(newX, vel.Y, newZ)
end)

print("✓ Nebula Otomatik Speed Bypass Yüklendi!")
print("✓ Q tuşu: Speed Aç/Kapat")
print("✓ X tuşu: Speed Kapat")
print("✓ Bypass Hızı: " .. autoSpeedBypass)