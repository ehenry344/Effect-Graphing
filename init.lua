local RunService = game:GetService("RunService")

local MainFrame = script.Parent:WaitForChild("MainFrame")
local GraphFrame = MainFrame:WaitForChild("Graph") 
local FixtureFrame = MainFrame:WaitForChild("FixtureLayout") 

local GraphSettings = {
	Offset = {
		X = {
			Start = 0.05, 
			End = 0.1
		},
		Y = {
			Start = 0.5, 
			End = 0.0
		}
	},
	
	Sizes = { 
		Point = {3, 3}, 
		Moveable = {10, 10}
	}, 
	
	Colors = { 
		Point = Color3.fromRGB(170, 85, 255), 
		Moveable = {
			Color3.fromRGB(85, 255, 0), 
			Color3.fromRGB(255, 255, 0), 
			Color3.fromRGB(0, 0, 255),
			Color3.fromRGB(0, 255, 255),
			Color3.fromRGB(255, 0, 255)
		},
		Axis = Color3.fromRGB(255, 0, 0), 
		Interval = Color3.fromRGB(89, 89, 89)
	}, 
	
	StepMultiplier = 5, 
	
	Intervals = {
		X = 20, 
		Y = 20
	}
}


local FixtureSettings = { 
	FrameGap = 0.01, 
	
	Colors = { 
		Fixture = Color3.fromRGB(0, 170, 255)
	}
}

local EffectSettings = {
	Wave = {
		Waveform = function(phase)
			return math.cos(phase) + 1
		end,
		
		Period = math.pi * 10, 
		Step = math.pi / 200, 
		YMax = 4
	},
	
	NumFixtures = 20,
	MATricks = { 
		Groups = 2, 
		Blocks = 0,
		Wings = 0
	}
}

-- Waveform Graph Representation

-- centering offset for all points generated 
local xScaleOffset = (GraphSettings.Sizes.Point[1] / GraphFrame.AbsoluteSize.X) / 2
local yScaleOffset = (GraphSettings.Sizes.Point[2] / GraphFrame.AbsoluteSize.Y) / 2 

local GraphState = { 
	MoveableColorIndex = 1,
}

local function renderGraph()
	local xAxis = Instance.new("Frame") 

	xAxis.BorderSizePixel = 0
	xAxis.Size = UDim2.new(1, 0, 0, 1.5)
	xAxis.Position = UDim2.fromScale(0, GraphSettings.Offset.Y.Start / (1 + GraphSettings.Offset.Y.End))
	xAxis.BackgroundColor3 = GraphSettings.Colors.Axis
	xAxis.ZIndex = 1
	xAxis.Parent = GraphFrame 
	xAxis.Name = "XAxis"

	local yAxis = Instance.new("Frame") 

	yAxis.BorderSizePixel = 0
	yAxis.Size = UDim2.new(0, 1.5, 1, 0)
	yAxis.Position = UDim2.fromScale(GraphSettings.Offset.X.Start / (1 + GraphSettings.Offset.X.End) )
	yAxis.BackgroundColor3 = GraphSettings.Colors.Axis
	yAxis.ZIndex = 1
	yAxis.Parent = GraphFrame
	yAxis.Name = "YAxis"
	
	-- Render Interval Lines 
	
	-- X Intervals
	for iX = 1, GraphSettings.Intervals.X - 1 do 
		local newLine = Instance.new("Frame")
		
		newLine.BackgroundColor3 = GraphSettings.Colors.Interval
		newLine.BorderSizePixel = 0
		newLine.Size = UDim2.new(0, 1.5, 1, 0)
		newLine.Position = UDim2.fromScale(
			(iX - (GraphSettings.Offset.X.Start / (1 + GraphSettings.Offset.X.End))) / GraphSettings.Intervals.X - 0.004, 
			0
		)
		newLine.Transparency = 0.7
		newLine.ZIndex = 0
		newLine.Name = "X"..iX
		
		newLine.Parent = GraphFrame
	end
	-- Y Intervals
	for iY = 1, GraphSettings.Intervals.Y - 1 do 
		local newLine = Instance.new("Frame")

		newLine.BackgroundColor3 = GraphSettings.Colors.Interval
		newLine.BorderSizePixel = 0
		newLine.Size = UDim2.new(1, 0, 0, 1.5)
		newLine.Position = UDim2.fromScale(
			0, 
			(iY - (GraphSettings.Offset.Y.Start / (1 + GraphSettings.Offset.Y.End))) / GraphSettings.Intervals.Y - 0.004
		)
		newLine.Transparency = 0.7
		newLine.ZIndex = 0
		newLine.Name = "Y"..iY

		newLine.Parent = GraphFrame
	end
end

local function renderFunction()
	renderGraph() 
	
	local wave = EffectSettings.Wave
	
	-- hold all points
	local pointStorage = Instance.new("Folder") 
	
	pointStorage.Name = "Points"
	pointStorage.Parent = GraphFrame
	
	-- template point that all other points are based on
	local pointTemplate = Instance.new("Frame") 
	
	pointTemplate.Name = "2dpt" -- abbrev. 2 dimensional point
	pointTemplate.BorderSizePixel = 0
	pointTemplate.Size = UDim2.fromOffset(table.unpack(GraphSettings.Sizes.Point)) 
	pointTemplate.BackgroundColor3 = GraphSettings.Colors.Point
	pointTemplate.ZIndex = 2
	
	for phase = 0, wave.Period, wave.Step do 		
		local newPoint = pointTemplate:Clone()

		newPoint.Position = UDim2.fromScale(
			(((phase / wave.Period) - xScaleOffset) + GraphSettings.Offset.X.Start) / (1 + GraphSettings.Offset.X.End),
			(1 - ((wave.Waveform(phase) / wave.YMax) - yScaleOffset + GraphSettings.Offset.Y.Start)) / (1 + GraphSettings.Offset.Y.End)
		)
	
		newPoint.Parent = pointStorage
	end
	
	pointTemplate:Destroy()
	pointTemplate = nil 
end

local function generateMoveable()  
	local wave = EffectSettings.Wave 
	
	local moveScaleOffsetX = (GraphSettings.Sizes.Moveable[1] / GraphFrame.AbsoluteSize.X) / 4
	local moveScaleOffsetY = (GraphSettings.Sizes.Moveable[2] / GraphFrame.AbsoluteSize.Y) / 4
	
	local newMoveable = Instance.new("Frame")
	
	newMoveable.AnchorPoint = Vector2.new(0.5, 0.5) 
	newMoveable.Name = "moveablePoint"
	newMoveable.Size = UDim2.fromOffset(table.unpack(GraphSettings.Sizes.Moveable))
	newMoveable.BorderSizePixel = 0
	newMoveable.ZIndex = 3
	
	newMoveable.Position = UDim2.fromScale(
		GraphSettings.Offset.X.Start / (1 + GraphSettings.Offset.X.End), 
		GraphSettings.Offset.Y.Start / (1 + GraphSettings.Offset.Y.End) 
	)
	
	if GraphState.MoveableColorIndex > #GraphSettings.Colors.Moveable then 
		GraphState.MoveableColorIndex = 1
	end
	
	newMoveable.BackgroundColor3 = GraphSettings.Colors.Moveable[GraphState.MoveableColorIndex] 
	newMoveable.Parent = GraphFrame 
	
	GraphState.MoveableColorIndex += 1
	
	local currentStep = 0
	
	return function()
		if currentStep >= wave.Period then 
			currentStep = 0.0
		end
		
		newMoveable.Position = UDim2.fromScale(
			(((currentStep / wave.Period) - moveScaleOffsetX) + GraphSettings.Offset.X.Start) / (1 + GraphSettings.Offset.X.End),
			(1 - ((wave.Waveform(currentStep) / wave.YMax) - moveScaleOffsetY + GraphSettings.Offset.Y.Start)) / (1 + GraphSettings.Offset.Y.End)
		)
		
		currentStep += (wave.Step * GraphSettings.StepMultiplier)
		
		return currentStep 
	end
end

-- Fixture State Representation 

local function renderFixtures()
	local fixtureTemp = Instance.new("Frame")
	
	fixtureTemp.BorderSizePixel = 0 
	fixtureTemp.AnchorPoint = Vector2.new(0.1, 0.5) 
	fixtureTemp.BackgroundColor3 = FixtureSettings.Colors.Fixture 
	
	fixtureTemp.Size = UDim2.fromScale(
		(FixtureFrame.Size.X.Scale - (EffectSettings.NumFixtures*FixtureSettings.FrameGap)) / EffectSettings.NumFixtures, 
		0.5
	)

	local fixtureLabel = Instance.new("TextLabel")
	
	fixtureLabel.Size = UDim2.fromScale(1, 1/3)
	fixtureLabel.Position = UDim2.fromScale(0, 1/3) 
	fixtureLabel.BorderSizePixel = 0 
	fixtureLabel.BackgroundTransparency = 1
	fixtureLabel.Name = "Id"
	fixtureLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
	
	fixtureLabel.Parent = fixtureTemp
	
	for i = 1, EffectSettings.NumFixtures do 
		local newFixture = fixtureTemp:Clone()
		
		newFixture.Id.TextXAlignment = Enum.TextXAlignment.Center
		newFixture.Id.Text = "F-Id: "..i
		newFixture.Position = UDim2.fromScale(((i-1) / EffectSettings.NumFixtures) + FixtureSettings.FrameGap, 0.5) 
		newFixture.Name = i 
		
		newFixture.Parent = FixtureFrame
	end
	
	fixtureTemp:Destroy() 
	fixtureTemp = nil
end

renderFixtures()
renderFunction() 

local newMoveable = generateMoveable()

local phaseOffset = EffectSettings.Wave.Period / EffectSettings.NumFixtures
local FixtureColor = FixtureSettings.Colors.Fixture 

RunService.Heartbeat:Connect(function(dt)
	local step = newMoveable() -- Step the moveable 
	
	for i,v in pairs(FixtureFrame:GetChildren()) do 
		local fixtureId = tonumber(v.Name)
		local waveOutput = EffectSettings.Wave.Waveform(fixtureId * phaseOffset + step) / 2 	
		
		local newBackground = Color3.fromRGB(
			FixtureColor.R, 
			FixtureColor.G, 
			waveOutput * 255
		)		
		
		v.BackgroundColor3 = newBackground
	end
end)





