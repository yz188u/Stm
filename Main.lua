--[[Style Changer Bypass
]]--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- GUI references
local abilitiesFolder = player:WaitForChild("PlayerGui"):WaitForChild("InGameUI"):WaitForChild("Bottom"):WaitForChild("Abilities")
local originalButton = abilitiesFolder:WaitForChild("1")
local styleChangerButton = originalButton:Clone()
styleChangerButton.Name = "StyleChanger"
styleChangerButton.Parent = abilitiesFolder

-- Update label
local timerLabel = styleChangerButton:FindFirstChild("Timer")
if timerLabel then timerLabel.Text = "Style Changer Menu" end
local keybindLabel = styleChangerButton:FindFirstChild("Keybind")
if keybindLabel then keybindLabel.Text = "T" end

-- Add sounds
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

-- Cooldown visual
local cooldownFrame = styleChangerButton:FindFirstChild("Cooldown")
local uiGradient = cooldownFrame and cooldownFrame:FindFirstChild("UIGradient")
local cooldownTime = 60
local onCooldown = false

local function startCooldown()
	if not cooldownFrame or not uiGradient then return end
	onCooldown = true
	cooldownFrame.Visible = true
	uiGradient.Offset = Vector2.new(0, 0)
	local tween = TweenService:Create(uiGradient, TweenInfo.new(cooldownTime, Enum.EasingStyle.Linear), { Offset = Vector2.new(0, 1) })
	tween:Play()
	tween.Completed:Wait()
	cooldownFrame.Visible = false
	onCooldown = false
end

-- Button animation
local function createTween(instance, goal, time)
	return TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Quad), goal)
end

local function animatePress()
	createTween(styleChangerButton, {Size = styleChangerButton.Size + UDim2.new(0.1, 0, 0.1, 0)}, 0.1):Play()
end

local function animateRelease()
	createTween(styleChangerButton, {Size = originalButton.Size}, 0.1):Play()
end

styleChangerButton.MouseButton1Down:Connect(animatePress)
styleChangerButton.MouseButton1Up:Connect(animateRelease)
styleChangerButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then animatePress() end
end)
styleChangerButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then animateRelease() end
end)
styleChangerButton.MouseEnter:Connect(function() hoverSound:Play() end)

-- Keybind label
if keybindLabel then
	keybindLabel.Visible = false
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed then
			keybindLabel.Visible = input.UserInputType == Enum.UserInputType.Keyboard
		end
	end)
end

-- Style list
local rarityStyles = {
	["Master"] = {"Loki"},
	["World Class"] = {"Kaiser", "NEL Isagi", "NEL Rin", "Don Lorenzo", "Sae"},
	["Mythic"] = {"King", "NEL Bachira", "Kunigami", "Rin", "Aiku", "Shidou", "Yukimiya"},
	["Legendary"] = {"Karasu", "Reo", "Nagi"},
	["Epic"] = {"Igaguri", "Kurona", "Bachira", "Otoya", "Gagamaru", "Hiori"},
	["Rare"] = {"Isagi", "Chigiri"},
}

local rarityColors = {
	["Master"] = Color3.fromRGB(0, 0, 0),
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
dropdown.Parent = player.PlayerGui:WaitForChild("InGameUI")

-- Responsive
local uiScale = Instance.new("UIScale", dropdown)
local scale = 1
local function updateUIScale()
	scale = math.clamp(workspace.CurrentCamera.ViewportSize.Y / 1080, 0.7, 1.3)
	uiScale.Scale = scale
end
updateUIScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)

-- Scrolling frame
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

-- Auto revert logic
local originalStyle = "Reo"
local revertTimer

-- Loop
for _, rarity in ipairs({"Master", "World Class", "Mythic", "Legendary", "Epic", "Rare"}) do
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

			-- Auto-revert 20s
			if revertTimer then task.cancel(revertTimer) end
			revertTimer = task.delay(20, function()
				if player.PlayerStats.Style.Value ~= originalStyle then
					player.PlayerStats.Style.Value = originalStyle
					warn("Style is back to Reo!")
				end
			end)
		end)
	end

	local rowCount = math.ceil(#styles / 3)
	local totalHeight = rowCount * 88
	buttonFrame.Size = UDim2.new(1, 0, 0, totalHeight)
	rarityFrame.Size = UDim2.new(1, 0, 0, 60 + totalHeight)
end

local function updateCanvas()
	task.wait()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, (listLayout.AbsoluteContentSize.Y + 10) * (1 / scale))
end
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.defer(updateCanvas)

-- Toggle GUI
styleChangerButton.MouseButton1Click:Connect(function()
	if onCooldown then return end
	clickSound:Play()
	dropdown.Visible = not dropdown.Visible
	scrollFrame.CanvasPosition = Vector2.new(0, 0)
	startCooldown()
end)
