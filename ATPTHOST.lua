local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- สร้างตารางเพื่อเก็บตำแหน่งของประตูของแต่ละเผ่า
local tableRaceDoor = {}

-- หาตำแหน่งประตูของแต่ละเผ่าใน Workspace
for _, v in pairs(game.Workspace:GetDescendants()) do
    if string.find(v.Name, "Corridor") then
        tableRaceDoor[v.Name] = v.Door.Door.RightDoor.Union.CFrame
    end
end

-- ฟังก์ชันสำหรับกดปุ่ม T
local function pressT()
    VirtualInputManager:SendKeyEvent(true, "T", false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, "T", false, game)
    task.wait(1.5)
end

-- ฟังก์ชันตรวจสอบว่า Host อยู่ใกล้ประตูของตัวเองหรือไม่
local function checkHostAtDoor(hostPlayer)
    if hostPlayer and hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local race = hostPlayer.Data.Race.Value
        local targetName = race .. "Corridor"
        local targetCFrame = tableRaceDoor[targetName]

        if targetCFrame then
            local distance = (hostPlayer.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
            return distance < 10 -- ตรวจสอบว่า Host อยู่ใกล้ประตูในระยะ 10 หน่วยหรือไม่
        else
            warn("No door found for the race:", race)
        end
    end
    return false
end

-- ติดตาม DescendantAdded เพื่อตรวจสอบ Texture เป้าหมาย
local function monitorForTargetTexture(host1)
    local character = host1.Character or host1.CharacterAdded:Wait()

    character.DescendantAdded:Connect(function(newDescendant)
        if newDescendant:IsA("ParticleEmitter") and newDescendant.Texture == "http://www.roblox.com/asset/?id=7157487174" then
            print("Target Texture Detected on Host1!")

            -- Host2 กดปุ่ม T ทันทีเมื่อเงื่อนไขครบ
            if checkHostAtDoor(LocalPlayer) then
                pressT()
                print("Host2 pressed T because Host1 has the target Texture.")
            end
        end
    end)
end

-- ฟังก์ชันหลักสำหรับ Host1
local function host1Function()
    if checkHostAtDoor(LocalPlayer) and checkHostAtDoor(Players:FindFirstChild(_G.Host.Host2[1])) then
        pressT()
        print("Host1 pressed T because both Host1 and Host2 are at the door.")
    end
end

-- ฟังก์ชันหลักสำหรับ Host2
local function host2Function()
    local host1 = Players:FindFirstChild(_G.Host.Host1[1])
    if host1 then
        monitorForTargetTexture(host1)
    end
end

-- รอ 30 วิก่อนเริ่มทำงาน
task.wait(30)

-- ลูปหลัก
while true do
    if table.find(_G.Host.Host1, LocalPlayer.Name) then
        host1Function()
    elseif table.find(_G.Host.Host2, LocalPlayer.Name) then
        host2Function()
    end
    wait(1) -- ตรวจสอบซ้ำทุก 0.5 วินาที
end
