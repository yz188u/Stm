local Players = game:GetService("Players")  
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService") -- Ini udah ada dua, jadi cukup 1x aja bro

local player = Players.LocalPlayer  
local abilitiesFolder = player.PlayerGui:WaitForChild("InGameUI"):WaitForChild("Bottom"):WaitForChild("Abilities")  
  
-- Clone tombol  
local originalButton = abilitiesFolder:WaitForChild("1")  
local styleChangerButton = originalButton:Clone()  
styleChangerButton.Name = "StyleChanger"  
styleChangerButton.Parent = abilitiesFolder  
  
-- Ganti tampilan teks  
local timerLabel = styleChangerButton:FindFirstChild("Timer")  
if timerLabel and timerLabel:IsA("TextLabel") then  
	timerLabel.Text = "Style Changer Menu"  
end  
  
local keybindLabel = styleChangerButton:FindFirstChild("Keybind")  
if keybindLabel and keybindLabel:IsA("TextLabel") then  
	keybindLabel.Text = "T"  
end  

-- === Tambahin Sound ===
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://10066968815"
clickSound.Volume = 1
clickSound.Parent = styleChangerButton

local hoverSound = Instance.new("Sound")
hoverSound.SoundId = "rbxassetid://10066931761"
hoverSound.Volume = 1
hoverSound.Parent = styleChangerButton

-- Cooldown logic  
local cooldownFrame = styleChangerButton:FindFirstChild("Cooldown")  
local uiGradient = cooldownFrame and cooldownFrame:FindFirstChild("UIGradient")  
local cooldownTime = 1  
local onCooldown = false  
  
  
-- Fungsi animasi cooldown dengan UIGradient  
local function startCooldown()  
	if not cooldownFrame or not uiGradient then return end  
	onCooldown = true  
	cooldownFrame.Visible = true  
	  
	-- Set awal UIGradient untuk penuh di atas  
	uiGradient.Offset = Vector2.new(0, 0)  
  
	-- Tween untuk animasi turun ke bawah  
	local tweenInfo = TweenInfo.new(cooldownTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)  
	local tween = TweenService:Create(uiGradient, tweenInfo, {  
		Offset = Vector2.new(0, 1)  
	})  
	tween:Play()  
  
	-- Tunggu sampai tween selesai  
	tween.Completed:Wait()  
  
	-- Setelah cooldown selesai, sembunyikan frame cooldown dan izinkan tombol diklik lagi  
	cooldownFrame.Visible = false  
	onCooldown = false  
end  
  
-- Klik event  
styleChangerButton.MouseButton1Click:Connect(function()  
	if onCooldown then return end  
	clickSound:Play() -- <-- Play sound klik saat tombol diklik
	cycleStyle()  
	startCooldown()  
end)  
  
-- Animasi tombol saat ditekan dan dilepas (PC & Mobile)
local pressTween
local releaseTween

local function createTween(instance, goal, time)
	local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	return TweenService:Create(instance, info, goal)
end

local function animatePress()
	if pressTween then pressTween:Cancel() end
	pressTween = createTween(styleChangerButton, {
		Size = styleChangerButton.Size + UDim2.new(0.1, 0, 0.1, 0)
	}, 0.1)
	pressTween:Play()
end

local function animateRelease()
	if releaseTween then releaseTween:Cancel() end
	releaseTween = createTween(styleChangerButton, {
		Size = originalButton.Size
	}, 0.1)
	releaseTween:Play()
end

-- Support PC
styleChangerButton.MouseButton1Down:Connect(function()
	animatePress()
end)

styleChangerButton.MouseButton1Up:Connect(function()
	animateRelease()
end)

-- Support Mobile (Touch input)
styleChangerButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		animatePress()
	end
end)

styleChangerButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		animateRelease()
	end
end)

-- === Mainin hover sound pas mouse masuk ===
styleChangerButton.MouseEnter:Connect(function()
	hoverSound:Play()
end)

-- Keybind visibility
if keybindLabel and keybindLabel:IsA("TextLabel") then  
	keybindLabel.Visible = false  
  
	UserInputService.InputBegan:Connect(function(input, gameProcessed)  
		if gameProcessed then return end  
  
		if input.UserInputType == Enum.UserInputType.Keyboard then  
			keybindLabel.Visible = true  
		elseif input.UserInputType == Enum.UserInputType.Touch then  
			keybindLabel.Visible = false  
		end  
	end)  
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- GUI references
local abilitiesFolder = player:WaitForChild("PlayerGui"):WaitForChild("InGameUI"):WaitForChild("Bottom"):WaitForChild("Abilities")
local styleChangerButton = abilitiesFolder:WaitForChild("StyleChanger")

-- Sound setup
local function createSound(id, name)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = 1
	sound.Name = name
	sound.Parent = styleChangerButton
	return sound
end

local clickSound = createSound("10066968815", "ClickSound")
local hoverSound = createSound("10066931761", "HoverSound")

-- Tween function
local function createTween(instance, goal, time)
	local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	return TweenService:Create(instance, info, goal)
end

-- Style data
local rarityStyles = {
	["World Class"] = {"Kaiser", "NEL Isagi", "NEL Rin", "Don Lorenzo", "Sae"},
	["Mythic"] = {"King", "NEL Bachira", "Kunigami", "Rin", "Aiku", "Shidou", "Yukimiya"},
	["Legendary"] = {"Karasu", "Reo", "Nagi"},
	["Epic"] = {"Igaguri", "Kurona", "Bachira", "Otoya", "Gagamaru", "Hiori"},
	["Rare"] = {"Isagi", "Chigiri"},
}

local rarityColors = {
	["World Class"] = Color3.fromRGB(220, 220, 220),
	["Mythic"] = Color3.fromRGB(255, 50, 50),
	["Legendary"] = Color3.fromRGB(255, 215, 0),
	["Epic"] = Color3.fromRGB(128, 0, 128),
	["Rare"] = Color3.fromRGB(30, 144, 255),
}

-- UI Dropdown
local dropdown = Instance.new("ImageLabel")
dropdown.Size = UDim2.new(0, 320, 0, 400)
dropdown.Position = UDim2.new(0.5, 0, 0.5, -50)
dropdown.AnchorPoint = Vector2.new(0.5, 0.5)
dropdown.BackgroundTransparency = 1
dropdown.Image = "rbxassetid://94420981449604"
dropdown.ScaleType = Enum.ScaleType.Slice
dropdown.SliceCenter = Rect.new(10, 10, 90, 90)
dropdown.Visible = false
dropdown.Name = "Style"
dropdown.Parent = player:WaitForChild("PlayerGui"):WaitForChild("InGameUI")

-- UIScale agar responsif di semua device
local uiScale = Instance.new("UIScale", dropdown)
local scale = 1
local function updateUIScale()
	local screenY = workspace.CurrentCamera.ViewportSize.Y
	scale = math.clamp(screenY / 1080, 0.7, 1.3)
	uiScale.Scale = scale
end
updateUIScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)

-- Scrolling Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.5, 140, 0.5, 190)
scrollFrame.Position = UDim2.new(0, 15, 0, 5)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ClipsDescendants = true
scrollFrame.Parent = dropdown

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 18)
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Loop rarity dan styles
for _, rarity in ipairs({"World Class", "Mythic", "Legendary", "Epic", "Rare"}) do
	local styles = rarityStyles[rarity]
	local color = rarityColors[rarity] or Color3.new(1, 1, 1)

	local rarityFrame = Instance.new("Frame", scrollFrame)
	rarityFrame.Size = UDim2.new(1, 0, 0, 0)
	rarityFrame.BackgroundTransparency = 1

	local rarityLayout = Instance.new("UIListLayout", rarityFrame)
	rarityLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rarityLayout.Padding = UDim.new(0, 12)

	local header = Instance.new("TextLabel", rarityFrame)
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundTransparency = 1
	header.Text = rarity
	header.TextColor3 = color
	header.TextScaled = true
	header.Font = Enum.Font.GothamBold
	header.TextXAlignment = Enum.TextXAlignment.Center

	local separator = Instance.new("Frame", rarityFrame)
	separator.Size = UDim2.new(0.95, 0, 0, 2)
	separator.Position = UDim2.new(0.025, 0, 0, 0)
	separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	separator.BorderSizePixel = 0

	local buttonFrame = Instance.new("Frame", rarityFrame)
	buttonFrame.Size = UDim2.new(1, 0, 0, 0)
	buttonFrame.BackgroundTransparency = 1

	local grid = Instance.new("UIGridLayout", buttonFrame)
	grid.CellSize = UDim2.new(0, 80, 0, 80)
	grid.CellPadding = UDim2.new(0, 8, 0, 8)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center

	for _, styleName in ipairs(styles) do
		local button = Instance.new("ImageButton", buttonFrame)
		button.Size = UDim2.new(0, 80, 0, 80)
		button.Image = "rbxassetid://94420981449604"
		button.Name = styleName
		button.BackgroundTransparency = 1

		local bScale = Instance.new("UIScale", button)
		bScale.Scale = 1

		local label = Instance.new("TextLabel", button)
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = styleName
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold

		local constraint = Instance.new("UITextSizeConstraint", label)
		constraint.MaxTextSize = 18
		constraint.MinTextSize = 8

		button.MouseButton1Click:Connect(function()
			if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Style") then
				player.PlayerStats.Style.Value = styleName
			end
			dropdown.Visible = false
		end)
	end

	-- Hitung tinggi dari grid
	local rowCount = math.ceil(#styles / 3)
	local totalHeight = rowCount * 88
	buttonFrame.Size = UDim2.new(1, 0, 0, totalHeight)
	rarityFrame.Size = UDim2.new(1, 0, 0, 60 + totalHeight)
end

-- Update CanvasSize
local function updateCanvas()
	task.wait() -- Biar layout selesai dulu
	local totalHeight = listLayout.AbsoluteContentSize.Y
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, (totalHeight + 10) * (1 / scale))
end
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.defer(updateCanvas)

-- Toggle GUI
styleChangerButton.MouseButton1Click:Connect(function()
	dropdown.Visible = not dropdown.Visible
	scrollFrame.CanvasPosition = Vector2.new(0, 0)
end)
