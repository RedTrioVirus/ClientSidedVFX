local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local remotes = replicatedStorage.Remotes

local LocalPlayer = game.Players.LocalPlayer

-- functions for later


local function Bezier(t, p0, p1, p2)
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

-- Bezier Curves Cubic
local function lerp(a,b,t)
	return a + (b-a) * t
end



remotes.ClientTween.OnClientEvent:Connect(function(Object, TInfo, Properties)
	if Object then
		local tweenToPlay = tweenService:Create(Object, TweenInfo.new(unpack(TInfo)), Properties)
		tweenToPlay:Play()
	end
end)

local function createTweeningValue(Object)
	local tweeningValue = Instance.new("NumberValue")
	tweeningValue.Name = "TweeningValue"
	tweeningValue.Value = 0
	tweeningValue.Parent = Object
end

remotes.ClientBezier.OnClientEvent:Connect(function(Object, startingPosition, pointB, endPoint, timeToAchieve, lookAt, nonStationary, nonStationaryLookAt)
	if Object then
		
		if Object:FindFirstChild("TweeningValue") then
			Object:FindFirstChild("TweeningValue"):Destroy()
			createTweeningValue(Object)
		else
			createTweeningValue(Object)
		end
		
		if Object:IsA("Model") then
			if nonStationary then

				Object.TweeningValue.Value = 0
				local connection
				connection = Object.TweeningValue.Changed:Connect(function()
					Object:SetPrimaryPartCFrame(CFrame.new(Bezier(Object.TweeningValue.Value, startingPosition, pointB, endPoint.Position)))
					if lookAt and nonStationaryLookAt then
						Object:SetPrimaryPartCFrame(CFrame.lookAt(Object.PrimaryPart.Position, lookAt.Position))
					elseif lookAt then
						Object:SetPrimaryPartCFrame(CFrame.lookAt(Object.PrimaryPart.Position, lookAt))
					end
				end)
				tweenService:Create(Object.TweeningValue, TweenInfo.new(timeToAchieve, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = 1}):Play()
				
				
				coroutine.resume(coroutine.create(function()
					wait(timeToAchieve)
					if connection then
						connection:Disconnect()
					end
				end))
				
			else
				Object.TweeningValue.Value = 0
				local connection
				connection = Object.TweeningValue.Changed:Connect(function()
					Object:SetPrimaryPartCFrame(CFrame.new(Bezier(Object.TweeningValue.Value, startingPosition, pointB, endPoint)))
					if lookAt and nonStationaryLookAt then
						Object:SetPrimaryPartCFrame(CFrame.lookAt(Object.PrimaryPart.Position, lookAt.Position))
					elseif lookAt then
						Object:SetPrimaryPartCFrame(CFrame.lookAt(Object.PrimaryPart.Position, lookAt))
					end
				end)
				tweenService:Create(Object.TweeningValue, TweenInfo.new(timeToAchieve, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = 1}):Play()
				
				coroutine.resume(coroutine.create(function()
					wait(timeToAchieve)
					if connection then
						connection:Disconnect()
					end
				end))
				
			end
		else
			if nonStationary then

				Object.TweeningValue.Value = 0
				local connection
				connection = Object.TweeningValue.Changed:Connect(function()
					Object.CFrame = CFrame.new(Bezier(Object.TweeningValue.Value, startingPosition, pointB, endPoint.Position))
					if lookAt and nonStationaryLookAt then
						Object.CFrame = CFrame.lookAt(Object.Position, lookAt.Position)
					elseif lookAt then
						Object.CFrame = CFrame.lookAt(Object.Position, lookAt)
					end
				end)
				tweenService:Create(Object.TweeningValue, TweenInfo.new(timeToAchieve, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = 1}):Play()
				
				coroutine.resume(coroutine.create(function()
					wait(timeToAchieve)
					if connection then
						connection:Disconnect()
					end
				end))
				
			else
				Object.TweeningValue.Value = 0
				local connection
				connection = Object.TweeningValue.Changed:Connect(function()
					Object.CFrame = CFrame.new(Bezier(Object.TweeningValue.Value, startingPosition, pointB, endPoint))
					if lookAt and nonStationaryLookAt then
						Object.CFrame = CFrame.lookAt(Object.Position, lookAt.Position)
					elseif lookAt then
						Object.CFrame = CFrame.lookAt(Object.Position, lookAt)
					end
					
				end)
				tweenService:Create(Object.TweeningValue, TweenInfo.new(timeToAchieve, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = 1}):Play()
				
				coroutine.resume(coroutine.create(function()
					wait(timeToAchieve)
					if connection then
						connection:Disconnect()
					end
				end))
				
			end
		end
		

	end


end)

remotes.ClientCubic.OnClientEvent:Connect(function(Object, startingPosition, pointB, endPoint, timeToAchieve, timeEachIteration, lookAt, nonStationary, nonStationaryLookAt)
	if Object then

		if Object:IsA("Model") then
			if nonStationary then
				
				
				-- OriginalValues
				local Start = startingPosition
				local Middle = pointB
				local End = endPoint
				
				for i = 0,1,timeEachIteration do
					local A = lerp(Start, Middle, i)

					local B = lerp(Middle, End.Position, i)

					--
					local Path = lerp(A, B, i)

					--
					Object.PrimaryPart.Position = Path

					if lookAt and nonStationaryLookAt then
						Object:SetPrimaryPartCFrame(CFrame.lookAt(Object.PrimaryPart.Position, lookAt.Position))
					elseif lookAt then
						Object:SetPrimaryPartCFrame(CFrame.lookAt(Object.PrimaryPart.Position, lookAt))
					end

					--
					task.wait(0.015)
					--
				end
				
				

			else
				
				-- OriginalValues
				local Start = startingPosition
				local Middle = pointB
				local End = endPoint
				
				for i = 0,1,timeEachIteration do
					local A = lerp(Start, Middle, i)

					local B = lerp(Middle, End, i)

					--
					local Path = lerp(A, B, i)

					--
					Object.PrimaryPart.Position = Path

					if lookAt and nonStationaryLookAt then
						Object:SetPrimaryPartCFrame(CFrame.lookAt(Object.PrimaryPart.Position, lookAt.Position))
					elseif lookAt then
						Object:SetPrimaryPartCFrame(CFrame.lookAt(Object.PrimaryPart.Position, lookAt))
					end

					--
					task.wait(0.015)
					--
				end

			end
		else
			if nonStationary then

				-- OriginalValues
				local Start = startingPosition
				local Middle = pointB
				local End = endPoint

				for i = 0,1,timeEachIteration do
					local A = lerp(Start, Middle, i)

					local B = lerp(Middle, End.Position, i)

					--
					local Path = CubicCurve(A, B, i)

					--
					Object.Position = Path

					if lookAt and nonStationaryLookAt then
						Object.CFrame = CFrame.lookAt(Object.Position, lookAt.Position)
					elseif lookAt then
						Object.CFrame = CFrame.lookAt(Object.Position, lookAt)
					end

					--
					task.wait(0.015)
					--
				end

			else
				
				-- OriginalValues
				local Start = startingPosition
				local Middle = pointB
				local End = endPoint

				
				for i = 0,1,timeEachIteration do
					local A = lerp(Start, Middle, i)

					local B = lerp(Middle, End, i)

					--
					local Path = lerp(A, B, i)

					--
					Object.Position = Path

					if lookAt and nonStationaryLookAt then
						Object.CFrame = CFrame.lookAt(Object.Position, lookAt.Position)
					elseif lookAt then
						Object.CFrame = CFrame.lookAt(Object.Position, lookAt)
					end

					--
					task.wait(0.015)
					--
				end

			end
		end


	end


end)

remotes.DoEffect.OnClientEvent:Connect(function(effectName, args)
	local effectModule = require(replicatedStorage.Effects:FindFirstChild(effectName))
	
	if effectModule then
		effectModule.Effect(LocalPlayer, args)
	end
	
end)


local function updateNPC(NPC)
	local idleAnim = NPC:FindFirstChild("Idle")
	local anim = NPC.Humanoid.Animator:LoadAnimation(idleAnim)
	anim:Play()
end

for i, v in pairs(game.Workspace["Fight Season"].NPCs:GetChildren()) do
	updateNPC(v)
end

game.Workspace["Fight Season"].NPCs:Connect(function(child)
	updateNPC(child)
end)

