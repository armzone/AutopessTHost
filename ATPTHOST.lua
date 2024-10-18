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
        if v:FindFirstChild("Door") and v.Door:FindFirstChild("RightDoor") and v.Door.RightDoor:FindFirstChild("Union") then
            tableRaceDoor[v.Name] = v.Door.RightDoor.Union.CFrame
            print("Found door:", v.Name)
        else
            warn("Door structure not found for:", v.Name)
        end
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
    if hostPlayer and hostPlayer.Character then
        local character = hostPlayer.Character or hostPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local race = hostPlayer.Data.Race.Value
            local targetName = race .. "Corridor"
            local targetCFrame = tableRaceDoor[targetName]

            if targetCFrame then
                local distance = (humanoidRootPart.Position - targetCFrame.Position).Magnitude
                print("Distance from door:", distance)
                return distance < 10 -- ตรวจสอบว่า Host อยู่ใกล้ประตูในระยะ 10 หน่วยหรือไม่
            else
                warn("No door found for the race:", race)
            end
        else
            warn("HumanoidRootPart not found for", hostPlayer.Name)
        end
    end
    return false
end

-- ฟังก์ชันตรวจสอบว่า Host1 มี ActivationRing หรือไม่
local function checkForActivationRing(host1)
    local character = host1.Character or host1.CharacterAdded:Wait()
    for _, descendant in pairs(character:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") and descendant.Name == "ActivationRing" then
            return true -- พบ ActivationRing ใน Host1
        end
    end
    return false
end

-- ฟังก์ชันหลักสำหรับ Host1
local function host1Function()
    local host2 = Players:FindFirstChild(_G.Host.Host2[1])
    if checkHostAtDoor(LocalPlayer) and checkHostAtDoor(host2) then
        pressT()
        print("Host1 pressed T because both Host1 and Host2 are at the door.")
    end
end

-- ฟังก์ชันหลักสำหรับ Host2
local function host2Function()
    local host1 = Players:FindFirstChild(_G.Host.Host1[1])
    if checkHostAtDoor(LocalPlayer) and host1 and checkForActivationRing(host1) then
        pressT()
        print("Host2 pressed T because Host1 has ActivationRing.")
    end
end

-- ลูปหลักที่จะทำงานทุกๆ 0.5 วินาที
while true do
    if table.find(_G.Host.Host1, LocalPlayer.Name) then
        host1Function()
    elseif table.find(_G.Host.Host2, LocalPlayer.Name) then
        host2Function()
    end
    wait(0.5) -- รอ 5 วินาทีก่อนที่จะทำการตรวจสอบอีกครั้ง
end
