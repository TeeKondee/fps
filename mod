-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalizedPlayer or Players.LocalPlayer

-- UI & State Variables
local isSubmerged = false
local hotkey = Enum.KeyCode.E -- คีย์ลัดเริ่มต้น สามารถเปลี่ยนตรงนี้ได้หรือกดเปลี่ยนใน UI
local targetDepth = 4 -- ความลึกใด้ดิน (หน่วยเป็น Stud)

-- สร้าง GUI เมนู
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UndergroundMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 160)
mainFrame.Position = UDim2.new(0, 50, 0, 200)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleLabel.Text = "ระบบมุดดิน (Underground)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleLabel

-- ปุ่มเปิด/ปิด มุดดิน
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.Text = "สถานะ: ปกติ (OFF)"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

-- ปุ่มตั้งค่าคีย์ลัด
local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0.9, 0, 0, 35)
keyBtn.Position = UDim2.new(0.05, 0, 0, 105)
keyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
keyBtn.Text = "คีย์ลัด: E (คลิกเพื่อเปลี่ยน)"
keyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
keyBtn.TextSize = 12
keyBtn.Font = Enum.Font.SourceSans
keyBtn.Parent = mainFrame

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 6)
keyCorner.Parent = keyBtn

local waitingForKey = false

-- ฟังก์ชันจัดการการแสดงผลตัวละครและชื่อ
local function updateVisibility(submerge)
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")
	
	if humanoidRootPart then
		if submerge then
			-- ย้ายตำแหน่งตัวละครลงไปใต้ดิน
			humanoidRootPart.CFrame = humanoidRootPart.CFrame - Vector3.new(0, targetDepth, 0)
		end
	end
	
	-- ซ่อน/แสดง ป้ายชื่อบนหัว (BillboardGui / NameTag)
	if head then
		for _, child in ipairs(head:GetChildren()) do
			if child:IsA("BillboardGui") or child.Name == "NameTag" then
				child.Enabled = not submerge
			end
		end
	end
end

-- สลับสถานะมุดดิน
local function toggleSubmerge()
	isSubmerged = not isSubmerged
	if isSubmerged then
		toggleBtn.Text = "สถานะ: มุดดิน (ON)"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		toggleBtn.Text = "สถานะ: ปกติ (OFF)"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		-- รีเซ็ตตำแหน่งขึ้นมาปกติเล็กน้อยเมื่อปิด
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, targetDepth, 0)
		end
	end
	updateVisibility(isSubmerged)
end

toggleBtn.MouseButton1Click:Connect(toggleSubmerge)

-- ระบบเปลี่ยนคีย์ลัด
keyBtn.MouseButton1Click:Connect(function()
	waitingForKey = true
	keyBtn.Text = "กดปุ่มใดก็ได้..."
	keyBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if waitingForKey then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			hotkey = input.KeyCode
			keyBtn.Text = "คีย์ลัด: " .. hotkey.Name .. " (คลิกเพื่อเปลี่ยน)"
			keyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			waitingForKey = false
		end
		return
	end
	
	if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == hotkey then
			toggleSubmerge()
		end
	end
end)

-- ลูปคอยรักษาสถานะให้อยู่ใต้ดินตลอดเวลาที่เปิดใช้งาน
RunService.Stepped:Connect(function()
	if isSubmerged then
		local character = player.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				-- ล็อคไม่ให้ลอยขึ้นมาเองเวลาขยับตัว
				local currentPos = humanoidRootPart.Position
				-- ตรวจสอบว่าตำแหน่งต่ำลงไปหรือยัง ถ้ายังให้บังคับอยู่ใต้ดิน
			end
		end
	end
end)
