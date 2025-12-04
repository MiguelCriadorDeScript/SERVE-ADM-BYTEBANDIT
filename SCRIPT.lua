local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local head = character:WaitForChild("Head")
local mouse = player:GetMouse()

local ROTATION_RADIUS = 5
local ROTATION_SPEED = 2
local PARTS_HEIGHT = 2

local LEFT_CONFIG = {
	Size = Vector3.new(1, 3, 5),
	Color = Color3.fromRGB(0, 100, 255),
	Material = Enum.Material.Neon,
	Transparency = 0.47,
	Text = "BYTEBANDIT",
	TextColor = Color3.fromRGB(0, 0, 139)
}

local RIGHT_CONFIG = {
	Size = Vector3.new(1, 5, 3),
	Color = Color3.fromRGB(0, 100, 255),
	Material = Enum.Material.Neon,
	Transparency = 0.47,
	TextureID = "rbxassetid://126949284932250"
}

local TITLES = {
	"SUPREME ADMIN",
	"SERVER GOD",
	"DIVINE MODERATOR",
	"ROBLOX KING",
	"SUPREME HACKER",
	"INFINITE BYTEBANDIT",
	"ABSOLUTE POWER",
	"CONTROLLER",
	"SERVER MASTER"
}

local cooldowns = {
	C = false,
	X = false,
	Z = false,
	Q = false
}

local isFlinging = false
local flingQueue = {}
local activeAuras = {}
local walkFlingEnabled = false
local statusGui = nil
local strongWalkFling = false

local function enableWalkFling(strong)
	walkFlingEnabled = true
	strongWalkFling = strong or false
end

local function disableWalkFling()
	walkFlingEnabled = false
	strongWalkFling = false
end

local walkFlingConnection
walkFlingConnection = RunService.Heartbeat:Connect(function()
	if not character or not character.Parent or not rootPart or not rootPart.Parent or not humanoid then
		return
	end
	
	if walkFlingEnabled and strongWalkFling then
		rootPart.CFrame = rootPart.CFrame + humanoid.MoveVector * 0.5
		rootPart.RotVelocity = Vector3.new(9e9, 9e9, 9e9)
		rootPart.Velocity = Vector3.new(0, 0, 0)
	end
end)

local function createStatusGUI()
	if player.PlayerGui:FindFirstChild("ByteBanditStatus") then
		player.PlayerGui.ByteBanditStatus:Destroy()
	end
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ByteBanditStatus"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	local statusFrame = Instance.new("Frame")
	statusFrame.Name = "StatusFrame"
	statusFrame.Size = UDim2.new(0, 400, 0, 100)
	statusFrame.Position = UDim2.new(0.5, -200, 0, 20)
	statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	statusFrame.BorderSizePixel = 0
	statusFrame.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = statusFrame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 35)
	titleLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	titleLabel.BorderSizePixel = 0
	titleLabel.Text = "⚡ BYTEBANDIT SYSTEM ACTIVE ⚡"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = statusFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = titleLabel
	
	local walkFlingStatus = Instance.new("TextLabel")
	walkFlingStatus.Name = "WalkFlingStatus"
	walkFlingStatus.Size = UDim2.new(1, -20, 0, 25)
	walkFlingStatus.Position = UDim2.new(0, 10, 0, 40)
	walkFlingStatus.BackgroundTransparency = 1
	walkFlingStatus.Text = "💤 WALKFLING: STANDBY"
	walkFlingStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
	walkFlingStatus.TextSize = 14
	walkFlingStatus.Font = Enum.Font.GothamBold
	walkFlingStatus.TextXAlignment = Enum.TextXAlignment.Left
	walkFlingStatus.Parent = statusFrame
	
	local powerStatus = Instance.new("TextLabel")
	powerStatus.Name = "PowerStatus"
	powerStatus.Size = UDim2.new(1, -20, 0, 25)
	powerStatus.Position = UDim2.new(0, 10, 0, 68)
	powerStatus.BackgroundTransparency = 1
	powerStatus.Text = "⚡ POWERS: READY"
	powerStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
	powerStatus.TextSize = 14
	powerStatus.Font = Enum.Font.Gotham
	powerStatus.TextXAlignment = Enum.TextXAlignment.Left
	powerStatus.Parent = statusFrame
	
	statusGui = screenGui
	
	return screenGui, powerStatus, walkFlingStatus
end

local function updateWalkFlingStatus(active)
	if statusGui and statusGui:FindFirstChild("StatusFrame") then
		local wfStatus = statusGui.StatusFrame:FindFirstChild("WalkFlingStatus")
		if wfStatus then
			if active then
				wfStatus.Text = "🔥 WALKFLING: ACTIVE [STRONG MODE]"
				wfStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
			else
				wfStatus.Text = "💤 WALKFLING: STANDBY"
				wfStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
			end
		end
	end
end

local function updatePowerStatus(text, color)
	if statusGui and statusGui:FindFirstChild("StatusFrame") then
		local powerStatus = statusGui.StatusFrame:FindFirstChild("PowerStatus")
		if powerStatus then
			powerStatus.Text = text
			powerStatus.TextColor3 = color
		end
	end
end

local function createBlueAura(targetCharacter)
	local highlight = Instance.new("Highlight")
	highlight.Name = "BlueAuraHighlight"
	highlight.FillColor = Color3.fromRGB(0, 150, 255)
	highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
	highlight.FillTransparency = 0.4
	highlight.OutlineTransparency = 0.2
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = targetCharacter
	
	activeAuras[targetCharacter] = {highlight = highlight}
	
	return highlight
end

local function removeAura(targetCharacter)
	if activeAuras[targetCharacter] then
		local data = activeAuras[targetCharacter]
		if data.highlight and data.highlight.Parent then
			data.highlight:Destroy()
		end
		activeAuras[targetCharacter] = nil
	end
end

local function flingTargetPlayer(targetCharacter)
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
	
	if not targetRoot or not targetHumanoid then
		removeAura(targetCharacter)
		return
	end
	
	local originalPosition = rootPart.CFrame
	
	targetRoot.Anchored = false
	targetHumanoid.PlatformStand = true
	
	enableWalkFling(true)
	updateWalkFlingStatus(true)
	
	local flingActive = true
	local spinAngle = 0
	local flingStartTime = tick()
	
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.P = 5000
	bodyVelocity.Parent = targetRoot
	
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyAngularVelocity.P = 5000
	bodyAngularVelocity.Parent = targetRoot
	
	task.spawn(function()
		while flingActive and (tick() - flingStartTime) < 5 do
			spinAngle = spinAngle + math.rad(30)
			
			local distance = 3
			local offsetX = math.cos(spinAngle) * distance
			local offsetZ = math.sin(spinAngle) * distance
			local offsetY = math.random(-2, 3)
			
			rootPart.CFrame = targetRoot.CFrame + Vector3.new(offsetX, offsetY, offsetZ)
			rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, spinAngle, 0)
			
			bodyVelocity.Velocity = Vector3.new(
				math.random(-400, 400),
				math.random(200, 700),
				math.random(-400, 400)
			)
			
			bodyAngularVelocity.AngularVelocity = Vector3.new(
				math.random(-250, 250),
				math.random(-250, 250),
				math.random(-250, 250)
			)
			
			RunService.Heartbeat:Wait()
		end
	end)
	
	wait(5)
	
	flingActive = false
	
	if bodyVelocity and bodyVelocity.Parent then
		bodyVelocity:Destroy()
	end
	if bodyAngularVelocity and bodyAngularVelocity.Parent then
		bodyAngularVelocity:Destroy()
	end
	
	targetHumanoid.PlatformStand = false
	
	removeAura(targetCharacter)
	
	disableWalkFling()
	updateWalkFlingStatus(false)
	
	rootPart.Anchored = true
	rootPart.Velocity = Vector3.new(0, 0, 0)
	rootPart.RotVelocity = Vector3.new(0, 0, 0)
	
	wait(1)
	
	local function findNearestSolidGround()
		local searchRadius = 100
		local bestPosition = originalPosition
		local bestDistance = math.huge
		
		for angle = 0, 360, 15 do
			for distance = 3, searchRadius, 3 do
				local checkPos = originalPosition.Position + Vector3.new(
					math.cos(math.rad(angle)) * distance,
					0,
					math.sin(math.rad(angle)) * distance
				)
				
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {character}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				
				local result = workspace:Raycast(checkPos + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), raycastParams)
				
				if result and result.Instance and result.Instance.CanCollide then
					local distanceFromOriginal = (result.Position - originalPosition.Position).Magnitude
					if distanceFromOriginal < bestDistance then
						bestPosition = CFrame.new(result.Position + Vector3.new(0, 3, 0))
						bestDistance = distanceFromOriginal
					end
				end
			end
		end
		
		return bestPosition
	end
	
	local safePosition = findNearestSolidGround()
	rootPart.CFrame = safePosition
	rootPart.Anchored = false
	rootPart.Velocity = Vector3.new(0, 0, 0)
	rootPart.RotVelocity = Vector3.new(0, 0, 0)
end

local function processFlingingQueue()
	while #flingQueue > 0 do
		local targetChar = table.remove(flingQueue, 1)
		if targetChar and targetChar.Parent then
			flingTargetPlayer(targetChar)
			wait(0.5)
		end
	end
	
	isFlinging = false
end

local function createLeftPart()
	local part = Instance.new("Part")
	part.Name = "LeftPart_BYTEBANDIT"
	part.Size = LEFT_CONFIG.Size
	part.Color = LEFT_CONFIG.Color
	part.Material = LEFT_CONFIG.Material
	part.Transparency = LEFT_CONFIG.Transparency
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace
	
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Left
	surfaceGui.AlwaysOnTop = true
	surfaceGui.Parent = part
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = LEFT_CONFIG.Text
	textLabel.TextColor3 = LEFT_CONFIG.TextColor
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = surfaceGui
	
	local light = Instance.new("PointLight")
	light.Brightness = 3
	light.Range = 10
	light.Color = LEFT_CONFIG.Color
	light.Parent = part
	
	return part
end

local function createRightPart()
	local part = Instance.new("Part")
	part.Name = "RightPart_Texture"
	part.Size = RIGHT_CONFIG.Size
	part.Color = RIGHT_CONFIG.Color
	part.Material = RIGHT_CONFIG.Material
	part.Transparency = RIGHT_CONFIG.Transparency
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace
	
	local decal = Instance.new("Decal")
	decal.Face = Enum.NormalId.Left
	decal.Texture = RIGHT_CONFIG.TextureID
	decal.Transparency = 0
	decal.Parent = part
	
	local light = Instance.new("PointLight")
	light.Brightness = 3
	light.Range = 10
	light.Color = RIGHT_CONFIG.Color
	light.Parent = part
	
	return part
end

local function createHeadText()
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "AdminText"
	billboardGui.Size = UDim2.new(0, 200, 0, 80)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = head
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "MainText"
	textLabel.Size = UDim2.new(1, 0, 0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "SERVER ADM BYTEBANDIT"
	textLabel.TextColor3 = Color3.fromRGB(0, 100, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = billboardGui
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleText"
	titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
	titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = TITLES[1]
	titleLabel.TextColor3 = Color3.fromRGB(135, 206, 250)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.TextStrokeTransparency = 0.5
	titleLabel.Parent = billboardGui
	
	return titleLabel
end

local lastPosition = rootPart.Position
local lastStepTime = 0

local function createFloorBlock(position)
	local block = Instance.new("Part")
	block.Name = "BlueFootprint"
	block.Size = Vector3.new(4, 0.5, 4)
	block.Position = position
	block.Anchored = true
	block.CanCollide = false
	block.Material = Enum.Material.Neon
	block.Color = Color3.fromRGB(0, 100, 255)
	block.Transparency = 0.3
	block.Parent = workspace
	
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Color = ColorSequence.new(Color3.fromRGB(0, 100, 255))
	particles.Size = NumberSequence.new(0.5, 1)
	particles.Rate = 30
	particles.Lifetime = NumberRange.new(1, 2)
	particles.Speed = NumberRange.new(2, 5)
	particles.SpreadAngle = Vector2.new(45, 45)
	particles.Parent = block
	
	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Range = 8
	light.Color = Color3.fromRGB(0, 100, 255)
	light.Parent = block
	
	task.delay(5, function()
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local goal = {Transparency = 1}
		local tween = TweenService:Create(block, tweenInfo, goal)
		tween:Play()
		particles.Enabled = false
		task.wait(1)
		block:Destroy()
	end)
end

local function createControlsGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ByteBanditControls"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "ControlsFrame"
	mainFrame.Size = UDim2.new(0, 250, 0, 320)
	mainFrame.Position = UDim2.new(1, -270, 0.5, -160)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
	title.BorderSizePixel = 0
	title.Text = "CONTROLS"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = title
	
	local controls = {
		{key = "C", desc = "Flying Blocks Fling"},
		{key = "X", desc = "Instant Target Fling"},
		{key = "Z", desc = "Teleport to Mouse"},
		{key = "Q", desc = "Explosion Area Fling"}
	}
	
	for i, control in ipairs(controls) do
		local controlFrame = Instance.new("Frame")
		controlFrame.Name = "Control"..i
		controlFrame.Size = UDim2.new(1, -20, 0, 60)
		controlFrame.Position = UDim2.new(0, 10, 0, 50 + (i-1) * 65)
		controlFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		controlFrame.BorderSizePixel = 0
		controlFrame.Parent = mainFrame
		
		local controlCorner = Instance.new("UICorner")
		controlCorner.CornerRadius = UDim.new(0, 8)
		controlCorner.Parent = controlFrame
		
		local button = Instance.new("TextButton")
		button.Name = "KeyButton"
		button.Size = UDim2.new(0, 50, 0, 50)
		button.Position = UDim2.new(0, 5, 0.5, -25)
		button.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
		button.BorderSizePixel = 0
		button.Text = control.key
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 24
		button.Font = Enum.Font.GothamBold
		button.Parent = controlFrame
		
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = button
		
		local desc = Instance.new("TextLabel")
		desc.Name = "Description"
		desc.Size = UDim2.new(1, -70, 1, 0)
		desc.Position = UDim2.new(0, 65, 0, 0)
		desc.BackgroundTransparency = 1
		desc.Text = control.desc
		desc.TextColor3 = Color3.fromRGB(200, 200, 200)
		desc.TextSize = 14
		desc.Font = Enum.Font.Gotham
		desc.TextWrapped = true
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.Parent = controlFrame
		
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
		end)
		
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
		end)
	end
	
	return screenGui, controls
end

local function powerFlyingBlocks()
	if cooldowns.C then 
		updatePowerStatus("⏳ POWER C: COOLDOWN", Color3.fromRGB(255, 150, 0))
		return 
	end
	if isFlinging then return end
	cooldowns.C = true
	isFlinging = true
	
	updatePowerStatus("🔥 POWER C: ACTIVE - BLOCKS SPAWNING", Color3.fromRGB(0, 255, 0))
	
	local blocks = {}
	
	for i = 1, 20 do
		local block = Instance.new("Part")
		block.Name = "FlyingBlock"
		block.Size = Vector3.new(2, 2, 2)
		block.Material = Enum.Material.Neon
		block.Color = Color3.fromRGB(0, 100, 255)
		block.Anchored = false
		block.CanCollide = true
		
		for _, face in pairs(Enum.NormalId:GetEnumItems()) do
			local decal = Instance.new("Decal")
			decal.Face = face
			decal.Texture = RIGHT_CONFIG.TextureID
			decal.Parent = block
		end
		
		local offset = Vector3.new(
			math.random(-8, 8),
			-3,
			math.random(-8, 8)
		)
		block.Position = rootPart.Position + offset
		block.Parent = workspace
		
		local light = Instance.new("PointLight")
		light.Brightness = 3
		light.Range = 8
		light.Color = Color3.fromRGB(0, 100, 255)
		light.Parent = block
		
		table.insert(blocks, block)
		wait(0.05)
	end
	
	wait(1)
	
	updatePowerStatus("🔥 POWER C: ACTIVE - BLOCKS READY", Color3.fromRGB(0, 255, 0))
	
	for i, block in pairs(blocks) do
		block.Anchored = true
		local behindPosition = rootPart.Position + (rootPart.CFrame.LookVector * -8) + Vector3.new(
			math.random(-3, 3),
			3 + i * 0.3,
			math.random(-3, 3)
		)
		block.Position = behindPosition
	end
	
	task.spawn(function()
		for _, block in pairs(blocks) do
			task.spawn(function()
				wait(0.5)
				
				local targetPos = mouse.Hit.Position
				local direction = (targetPos - block.Position).Unit
				
				block.Anchored = false
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = direction * 100
				bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bodyVelocity.Parent = block
				
				block.Touched:Connect(function(hit)
					local targetCharacter = hit.Parent
					local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
					if targetHumanoid and targetCharacter ~= character then
						if not table.find(flingQueue, targetCharacter) then
							table.insert(flingQueue, targetCharacter)
							createBlueAura(targetCharacter)
							updatePowerStatus("💀 POWER C: TARGET MARKED", Color3.fromRGB(255, 0, 0))
						end
						block:Destroy()
					elseif hit:IsA("Part") and hit.Parent ~= character and not hit.Parent:FindFirstChild("Humanoid") then
						block:Destroy()
					end
				end)
				
				task.delay(10, function()
					if block and block.Parent then
						block:Destroy()
					end
				end)
			end)
		end
		
		wait(8)
		if #flingQueue > 0 then
			updatePowerStatus("💀 POWER C: FLINGING "..#flingQueue.." TARGETS", Color3.fromRGB(255, 0, 0))
		end
		processFlingingQueue()
		updatePowerStatus("⚡ POWERS: READY", Color3.fromRGB(200, 200, 200))
	end)
	
	wait(15)
	cooldowns.C = false
	updatePowerStatus("⚡ POWERS: READY", Color3.fromRGB(200, 200, 200))
end

local function powerInstantFling()
	if cooldowns.X then 
		updatePowerStatus("⏳ POWER X: COOLDOWN", Color3.fromRGB(255, 150, 0))
		return 
	end
	if isFlinging then return end
	cooldowns.X = true
	isFlinging = true
	
	updatePowerStatus("🔥 POWER X: TARGETING", Color3.fromRGB(0, 255, 0))
	
	local target = mouse.Target
	if target then
		local targetCharacter = target.Parent
		local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
		
		if targetHumanoid and targetCharacter ~= character then
			table.insert(flingQueue, targetCharacter)
			createBlueAura(targetCharacter)
			updatePowerStatus("💀 POWER X: FLINGING TARGET", Color3.fromRGB(255, 0, 0))
			processFlingingQueue()
		else
			isFlinging = false
			updatePowerStatus("❌ POWER X: NO TARGET", Color3.fromRGB(255, 0, 0))
		end
	else
		isFlinging = false
		updatePowerStatus("❌ POWER X: NO TARGET", Color3.fromRGB(255, 0, 0))
	end
	
	wait(5)
	cooldowns.X = false
	updatePowerStatus("⚡ POWERS: READY", Color3.fromRGB(200, 200, 200))
end

local function powerTeleport()
	if cooldowns.Z then 
		updatePowerStatus("⏳ POWER Z: COOLDOWN", Color3.fromRGB(255, 150, 0))
		return 
	end
	cooldowns.Z = true
	
	updatePowerStatus("⚡ POWER Z: TELEPORTING", Color3.fromRGB(0, 255, 255))
	
	local targetPos = mouse.Hit.Position
	
	local effect = Instance.new("Part")
	effect.Size = Vector3.new(4, 4, 4)
	effect.Position = rootPart.Position
	effect.Anchored = true
	effect.CanCollide = false
	effect.Transparency = 0.5
	effect.Material = Enum.Material.Neon
	effect.Color = Color3.fromRGB(0, 100, 255)
	effect.Parent = workspace
	
	rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
	
	local effect2 = effect:Clone()
	effect2.Position = rootPart.Position
	effect2.Parent = workspace
	
	task.delay(0.5, function()
		effect:Destroy()
		effect2:Destroy()
	end)
	
	wait(2)
	cooldowns.Z = false
	updatePowerStatus("⚡ POWERS: READY", Color3.fromRGB(200, 200, 200))
end

local function powerExplosionFling()
	if cooldowns.Q then 
		updatePowerStatus("⏳ POWER Q: COOLDOWN", Color3.fromRGB(255, 150, 0))
		return 
	end
	if isFlinging then return end
	cooldowns.Q = true
	isFlinging = true
	
	updatePowerStatus("💥 POWER Q: EXPLOSION ACTIVE", Color3.fromRGB(255, 0, 0))
	
	local explosion = Instance.new("Part")
	explosion.Name = "Explosion"
	explosion.Shape = Enum.PartType.Ball
	explosion.Size = Vector3.new(1, 1, 1)
	explosion.Position = rootPart.Position
	explosion.Anchored = true
	explosion.CanCollide = false
	explosion.Material = Enum.Material.Neon
	explosion.Color = Color3.fromRGB(255, 0, 0)
	explosion.Transparency = 0.3
	explosion.Parent = workspace
	
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {Size = Vector3.new(50, 50, 50), Transparency = 1}
	local tween = TweenService:Create(explosion, tweenInfo, goal)
	tween:Play()
	
	local targetsFound = 0
	
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local otherChar = otherPlayer.Character
			if otherChar then
				local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
				
				if otherRoot then
					local distance = (otherRoot.Position - rootPart.Position).Magnitude
					
					if distance <= 25 then
						if not table.find(flingQueue, otherChar) then
							table.insert(flingQueue, otherChar)
							createBlueAura(otherChar)
							targetsFound = targetsFound + 1
						end
					end
				end
			end
		end
	end
	
	task.delay(0.5, function()
		explosion:Destroy()
	end)
	
	wait(1)
	
	if targetsFound > 0 then
		updatePowerStatus("💀 POWER Q: FLINGING "..targetsFound.." TARGETS", Color3.fromRGB(255, 0, 0))
	else
		updatePowerStatus("❌ POWER Q: NO TARGETS IN RANGE", Color3.fromRGB(255, 150, 0))
	end
	
	processFlingingQueue()
	
	wait(12)
	cooldowns.Q = false
	updatePowerStatus("⚡ POWERS: READY", Color3.fromRGB(200, 200, 200))
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.C then
		powerFlyingBlocks()
	elseif input.KeyCode == Enum.KeyCode.X then
		powerInstantFling()
	elseif input.KeyCode == Enum.KeyCode.Z then
		powerTeleport()
	elseif input.KeyCode == Enum.KeyCode.Q then
		powerExplosionFling()
	end
end)

local leftPart = createLeftPart()
local rightPart = createRightPart()
local titleLabel = createHeadText()
local controlsGUI, controls = createControlsGUI()
local statusGUIInstance, powerStatusLabel, walkFlingStatusLabel = createStatusGUI()

for i, control in ipairs(controls) do
	local button = controlsGUI.ControlsFrame["Control"..i].KeyButton
	button.MouseButton1Click:Connect(function()
		if control.key == "C" then
			powerFlyingBlocks()
		elseif control.key == "X" then
			powerInstantFling()
		elseif control.key == "Z" then
			powerTeleport()
		elseif control.key == "Q" then
			powerExplosionFling()
		end
	end)
end

task.spawn(function()
	while true do
		wait(2)
		if titleLabel and titleLabel.Parent then
			local randomTitle = TITLES[math.random(1, #TITLES)]
			titleLabel.Text = randomTitle
		end
	end
end)

local angle = 0

RunService.Heartbeat:Connect(function(deltaTime)
	if not rootPart or not rootPart.Parent then return end
	
	angle = angle + (ROTATION_SPEED * deltaTime)
	local basePosition = rootPart.Position + Vector3.new(0, PARTS_HEIGHT, 0)
	
	if leftPart and leftPart.Parent then
		local leftOffset = Vector3.new(
			math.cos(angle) * ROTATION_RADIUS,
			0,
			math.sin(angle) * ROTATION_RADIUS
		)
		leftPart.CFrame = CFrame.new(basePosition + leftOffset) * CFrame.Angles(0, angle, 0)
	end
	
	if rightPart and rightPart.Parent then
		local rightOffset = Vector3.new(
			math.cos(angle + math.pi) * ROTATION_RADIUS,
			0,
			math.sin(angle + math.pi) * ROTATION_RADIUS
		)
		rightPart.CFrame = CFrame.new(basePosition + rightOffset) * CFrame.Angles(0, angle + math.pi, 0)
	end
	
	local currentPosition = rootPart.Position
	local distance = (currentPosition - lastPosition).Magnitude
	local currentTime = tick()
	
	if distance > 3 and (currentTime - lastStepTime) > 0.3 and not isFlinging then
		local floorPosition = Vector3.new(currentPosition.X, currentPosition.Y - 3, currentPosition.Z)
		createFloorBlock(floorPosition)
		lastPosition = currentPosition
		lastStepTime = currentTime
	end
end)

humanoid.Died:Connect(function()
	if leftPart then leftPart:Destroy() end
	if rightPart then rightPart:Destroy() end
	isFlinging = false
	flingQueue = {}
	for char, data in pairs(activeAuras) do
		removeAura(char)
	end
end)

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	rootPart = newCharacter:WaitForChild("HumanoidRootPart")
	humanoid = newCharacter:WaitForChild("Humanoid")
	head = newCharacter:WaitForChild("Head")
	mouse = player:GetMouse()
	
	isFlinging = false
	flingQueue = {}
	activeAuras = {}
	walkFlingEnabled = false
	strongWalkFling = false
	
	wait(0.5)
	
	leftPart = createLeftPart()
	rightPart = createRightPart()
	titleLabel = createHeadText()
	
	if not player.PlayerGui:FindFirstChild("ByteBanditControls") then
		controlsGUI, controls = createControlsGUI()
		for i, control in ipairs(controls) do
			local button = controlsGUI.ControlsFrame["Control"..i].KeyButton
			button.MouseButton1Click:Connect(function()
				if control.key == "C" then
					powerFlyingBlocks()
				elseif control.key == "X" then
					powerInstantFling()
				elseif control.key == "Z" then
					powerTeleport()
				elseif control.key == "Q" then
					powerExplosionFling()
				end
			end)
		end
	end
	
	if not player.PlayerGui:FindFirstChild("ByteBanditStatus") then
		statusGUIInstance, powerStatusLabel, walkFlingStatusLabel = createStatusGUI()
	end
	
	lastPosition = rootPart.Position
	lastStepTime = 0
	
	humanoid.Died:Connect(function()
		if leftPart then leftPart:Destroy() end
		if rightPart then rightPart:Destroy() end
		isFlinging = false
		flingQueue = {}
		disableWalkFling()
		for char, data in pairs(activeAuras) do
			removeAura(char)
		end
	end)
end)