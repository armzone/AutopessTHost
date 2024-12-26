local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local texturePlayers = {}
local requiredCount = 2
local debounceTime = 1.5
local lastPressTime = 0

-- ฟังก์ชันสำหรับกดปุ่ม T
local function pressT()
    if tick() - lastPressTime >= debounceTime then
        lastPressTime = tick()
        VirtualInputManager:SendKeyEvent(true, "T", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "T", false, game)
        print("Pressed T because 2 players activated the Texture simultaneously.")
        texturePlayers = {}
    end
end

-- ฟังก์ชันเช็ค Texture เป้าหมาย
local function isValidTexture(descendant)
    local success, result = pcall(function()
        if descendant and descendant:IsA("ParticleEmitter") then
            return descendant.Texture == "http://www.roblox.com/asset/?id=7157487174"
        end
        return false
    end)

    if not success then
        warn("Error in isValidTexture: " .. tostring(result))
    end
    return result
end

-- ฟังก์ชันตรวจสอบ DescendantAdded ของผู้เล่น
local function monitorForConditions(player)
    player.CharacterAdded:Connect(function(character)
        character.DescendantAdded:Connect(function(newDescendant)
            local success = pcall(function()
                if newDescendant and isValidTexture(newDescendant) and not texturePlayers[player.Name] then
                    texturePlayers[player.Name] = true
                    print(player.Name .. " activated the target Texture!")

                    local validCount = 0
                    for _, _ in pairs(texturePlayers) do
                        validCount = validCount + 1
                    end

                    if validCount == requiredCount then
                        pressT()
                    end
                end
            end)

            if not success then
                warn("Error in DescendantAdded for player: " .. player.Name)
            end
        end)
    end)

    if player.Character then
        monitorForConditions(player)
    end
end

-- ฟังก์ชันสำหรับเริ่มต้นตรวจสอบผู้เล่นทั้งหมด
local function startMonitoring()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            monitorForConditions(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        monitorForConditions(player)
    end)
end

-- เริ่มต้นการตรวจสอบ
startMonitoring()
