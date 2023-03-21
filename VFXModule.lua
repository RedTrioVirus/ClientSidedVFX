-- made by RedTrio#7989 / VulkanAPI

-- services
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

-- variable shortcuts
local remotes = replicatedStorage.Remotes

local module = {}

local tweenThreads = {}

local function clientTweenEnded(instance, properties)
	tweenThreads[instance] = nil
	for index, property in properties do
		instance[index] = property
	end
end

module.ClientTween = function(instance, tweenInfo, properties, replicate, roomForError)
	if tweenThreads[instance] ~= nil then
		task.cancel(tweenThreads[instance])
		tweenThreads[instance] = nil
	end
	
	remotes.ClientTween:FireAllClients(instance, tweenInfo, properties)
	
	if tweenInfo[5] == true then return end
	local repeatCount = tweenInfo[4] or 0
	if repeatCount < 0 then return end
	local delayTime = tweenInfo[6] or 0
	local tweenTime = tweenInfo[1] or 1
	replicate = replicate or true
	roomForError = roomForError or 0.05
	
	if replicate then
		tweenThreads[instance] = task.delay((delayTime + tweenTime - roomForError) * (repeatCount + 1), clientTweenEnded, instance, properties)
	end
	
end

-- Grow and Shrink tween
module.GrowShrink = function(object, tweenTime, synchronized, easingStyle, easingDirection, xAdd, yAdd, zAdd, replicate, roomForError)
	
	local Growing = false
	
	tweenTime = tweenTime or 1
	synchronized = synchronized or false
	easingStyle = easingStyle or Enum.EasingStyle.Linear
	easingDirection = easingDirection or Enum.EasingDirection.InOut
	xAdd = xAdd or 1
	yAdd = yAdd or 1
	zAdd = zAdd or 1
	
	if synchronized then
		yAdd = xAdd
		zAdd = xAdd
	end
	
	local function Tween()
		if Growing == false then
			Growing = true
			module.ClientTween(object,{tweenTime,easingStyle,easingDirection},{Size = object.Size + Vector3.new(xAdd,yAdd,zAdd)}, replicate, roomForError)
			
			wait(tweenTime)
			
			module.ClientTween(object,{tweenTime,easingStyle,easingDirection},{Size = object.Size - Vector3.new(xAdd,yAdd,zAdd)}, replicate, roomForError)
			
			wait(tweenTime)
			
			Growing = false
			Tween()
		end
	end
	
	coroutine.resume(coroutine.create(function()
		Tween()
	end))	
	
end

local bezierThreads = {}

local function clientBezierEnded(instance, endPoint, lookAt)
	bezierThreads[instance] = nil
	
	
	
	if instance:IsA("Model") then
		instance.PrimaryPart.Position = endPoint
		if lookAt then
			if typeof(lookAt) == "Vector3" then
				instance:SetPrimaryPartCFrame(CFrame.lookAt(instance.PrimaryPart.Position, lookAt))
			elseif typeof(lookAt) == "Instance" then
				instance:SetPrimaryPartCFrame(CFrame.lookAt(instance.PrimaryPart.Position, lookAt.Position))
			end
		end
	else
		instance.Position = endPoint
		if lookAt then
			if typeof(lookAt) == "Vector3" then
				instance.CFrame = CFrame.lookAt(instance.Position, lookAt)
			elseif typeof(lookAt) == "Instance" then
				instance.CFrame = CFrame.lookAt(instance.Position, lookAt.Position)
			end
			
		end
	end
	
end

--[[
Instance - what you're gonna be putting along the bezier : Instance
Starting Position - where the bezier is gonna start : Vector3
PointB - the point of influence of the bezier curve : Vector3
EndPoint - where the bezier is gonna end : Vector3
TimeToAchieve - how long it'll take for the instance to navigate the bezier in seconds : Number
LookAt - tells the instance to constantly look at the position provided : Vector3
NonStationary - determines if the position you're having the instance end at is stationary or not (i.e. a humanoidrootpart walking around) : Boolean
NonStationaryLookAt - determines if the position you're having the instance look at is stationary or not, will constantly update the orientation to the lookAt point (i.e. a humanoidrootpart walking around) : Boolean
Replicate - determines if the tween will replicate on the server or not : Boolean
RoomForError - time before the tween should end the server will replicate the changes, this helps ensure the instance arrive to the intended destination on time : Number
^ this can cause flickering issues if it's set too high, which is why it's a low amount by default (0.05 seconds) 
^ only really an issue with beziers that go very far in a short amount of time, or exponential easing styles where the instance doesn't start moving quickly till the end of the tween
]]

module.ClientBezier = function(instance, startingPosition, pointB, endPoint, timeToAchieve, lookAt, nonStationary, nonStationaryLookAt, replicate, roomForError)
	if bezierThreads[instance] ~= nil then
		task.cancel(bezierThreads[instance])
		bezierThreads[instance] = nil
	end
	
	lookAt = lookAt or nil
	timeToAchieve = timeToAchieve or 1
	replicate = replicate or true
	roomForError = roomForError or 0.05
	nonStationary = nonStationary or false
	
	remotes.ClientBezier:FireAllClients(instance, startingPosition, pointB, endPoint, timeToAchieve, lookAt, nonStationary, nonStationaryLookAt)


	if replicate then
		bezierThreads[instance] = task.delay((timeToAchieve - roomForError), clientBezierEnded, instance, endPoint, lookAt)
	end

end


-- just to have them for whatever reason
module.EnableParticle = function(particle)
	particle.Enabled = true
end

module.DisableParticle = function(particle)
	particle.Enabled = false
end

module.SetParticles = function(part, state, skipDontEnable)
	
	skipDontEnable = skipDontEnable or true
	
	for _,Particles in pairs(part:GetChildren()) do
		if Particles:IsA("ParticleEmitter") then
			if skipDontEnable and Particles:GetAttribute("DontEnable") then
				continue
			end
			task.defer(function()
				Particles.Enabled = state
			end)
		end
	end
	
end

module.EmitParticles = function(part, emit, skipDontEmit)
	skipDontEmit = skipDontEmit or true
	emit = emit or 10
	
	
	for _,Particles in pairs(part:GetChildren()) do
		if Particles:IsA("ParticleEmitter") then
			if skipDontEmit and Particles:GetAttribute("DontEmit") then
				continue
			end
			task.defer(function()
				if Particles:GetAttribute("EmitCount") then
					Particles:Emit(Particles:GetAttribute("EmitCount"))
				else
					Particles:Emit(emit)
				end
				
			end)
		end
	end
end

module.SetAllParticles = function(part, state, enableDontEnable)

	enableDontEnable = enableDontEnable or false
	state = state or true

	for _,Particles in pairs(part:GetDescendants()) do
		if Particles:IsA("ParticleEmitter") then
			if not enableDontEnable and Particles:GetAttribute("DontEnable") then
				continue
			end
			task.defer(function()
				Particles.Enabled = state
			end)
		end
	end

end

module.EmitAllParticles = function(part, emit, emitDontEmit)
	emitDontEmit = emitDontEmit or true
	emit = emit or 10


	for _,Particles in pairs(part:GetDescendants()) do
		if Particles:IsA("ParticleEmitter") then
			if not emitDontEmit and Particles:GetAttribute("DontEmit") then
				continue
			end
			task.defer(function()
				if Particles:GetAttribute("EmitCount") then
					Particles:Emit(Particles:GetAttribute("EmitCount"))
				else
					Particles:Emit(emit)
				end

			end)
		end
	end
end

local cubicThreads = {}

local function clientCubicEnded(instance, endPoint, lookAt)
	cubicThreads[instance] = nil



	if instance:IsA("Model") then
		instance.PrimaryPart.Position = endPoint
		if lookAt then
			if typeof(lookAt) == "Vector3" then
				instance:SetPrimaryPartCFrame(CFrame.lookAt(instance.PrimaryPart.Position, lookAt))
			elseif typeof(lookAt) == "Instance" then
				instance:SetPrimaryPartCFrame(CFrame.lookAt(instance.PrimaryPart.Position, lookAt.Position))
			end
		end
	else
		instance.Position = endPoint
		if lookAt then
			if typeof(lookAt) == "Vector3" then
				instance.CFrame = CFrame.lookAt(instance.Position, lookAt)
			elseif typeof(lookAt) == "Instance" then
				instance.CFrame = CFrame.lookAt(instance.Position, lookAt.Position)
			end

		end
	end

end

module.ClientCubicCurve = function(instance, startingPosition, pointB, endPoint, timeEachIteration, lookAt, nonStationary, nonStationaryLookAt, replicate, roomForError)
	if cubicThreads[instance] ~= nil then
		task.cancel(cubicThreads[instance])
		cubicThreads[instance] = nil
	end
	
	local timeToAchieve = (1/timeEachIteration) * 0.015 -- about the time each task.wait() happens / 0.015 ≈ 1 frame
	
	lookAt = lookAt or nil
	timeEachIteration = timeEachIteration or 0.01
	replicate = replicate or true
	roomForError = roomForError or 0.05
	nonStationary = nonStationary or false

	remotes.ClientCubic:FireAllClients(instance, startingPosition, pointB, endPoint, timeToAchieve, timeEachIteration, lookAt, nonStationary, nonStationaryLookAt)


	if replicate then
		cubicThreads[instance] = task.delay((timeToAchieve - roomForError), clientCubicEnded, instance, endPoint, lookAt)
	end
	
	return timeToAchieve
	
end

return module
