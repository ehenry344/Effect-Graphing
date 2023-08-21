local RunService = game:GetService("RunService")

local Settings = require(script.Parent.Settings)
local Offsets = Settings.Graph.Offsets

local GraphFrame = script.Parent.MainFrame.Graph

-- Proportionality Constants 

-- X / Y Scale (Point)
local X_SC = (Settings.Graph.Sizes.Point[1] / GraphFrame.AbsoluteSize.X) / 2 
local Y_SC = (Settings.Graph.Sizes.Point[2] / GraphFrame.AbsoluteSize.Y) / 2

-- X / Y Scale (Moveable Point) 
local X_SCM = (Settings.Graph.Sizes.Moveable[1] / GraphFrame.AbsoluteSize.X) / 4
local Y_SCM = (Settings.Graph.Sizes.Moveable[2] / GraphFrame.AbsoluteSize.Y) / 4
	
-- X / Y Proportionality
local X_PC = 1 - (Offsets.X.Start + Offsets.X.End) 
local Y_PC = 1 - (Offsets.Y.Start + Offsets.Y.End)


local Graph = {}
Graph.__index = Graph

function Graph.New(showEndBounds) 
	local self = {		
		Waveforms = {}, 
		Axis = {},
		Intervals = {}, 
		Connections = {}
	}
	
	-- X Axis
	local xAxis = Instance.new("Frame")
	
	xAxis.BorderSizePixel = 0
	xAxis.BackgroundColor3 = Settings.Graph.Colors.Axis
	xAxis.ZIndex = 1
	xAxis.Size = UDim2.new(1, 0, 0, 1.5) 
	xAxis.Name = "xAxis"
	xAxis.Position = UDim2.fromScale(0, 1 - Offsets.Y.Start)
	
	self.Axis["x"] = xAxis
	
	--Y Axis
	local yAxis = Instance.new("Frame")
	
	yAxis.BorderSizePixel = 0
	yAxis.BackgroundColor3 = Settings.Graph.Colors.Axis
	yAxis.ZIndex = 1
	yAxis.Size = UDim2.new(0, 1.5, 1, 0)
	yAxis.Name = "yAxis"
	yAxis.Position = UDim2.fromScale(Offsets.X.Start, 0)
	
	self.Axis["y"] = yAxis
	
	xAxis.Parent = GraphFrame
	yAxis.Parent = GraphFrame
	
	if Settings.Graph.ShowAllBounds then 
		self.EndBounds = {}
		
		local xEnd = Instance.new("Frame")
		
		xEnd.BorderSizePixel = 0
		xEnd.BackgroundColor3 = Settings.Graph.Colors.Axis
		xEnd.ZIndex = 1
		xEnd.Size = UDim2.new(1, 0, 0, 1.5)
		xEnd.Name = "xBound"
		xEnd.Position = UDim2.fromScale(0, 1 - Offsets.Y.End)
		
		self.EndBounds["x"] = xEnd
		
		local yEnd = Instance.new("Frame")
		
		yEnd.BorderSizePixel = 0
		yEnd.BackgroundColor3 = Settings.Graph.Colors.Axis
		yEnd.ZIndex = 1
		yEnd.Size = UDim2.new(0, 1.5, 1, 0)
		yEnd.Name = "yBound"
		yEnd.Position = UDim2.fromScale(1 - Offsets.X.End, 0)
		
		self.EndBounds["y"] = yEnd 
		
		xEnd.Parent = GraphFrame
		yEnd.Parent = GraphFrame 
	end
	
	setmetatable(self, Graph)
	
	self:_renderIntervals()
	
	return self
end

function Graph:_renderIntervals()	
	-- fix floating point errors 
	local xModifier = Settings.Graph.Intervals.X * Offsets.X.Start
	local xCorrection = ((xModifier - (Offsets.X.Start - Offsets.X.End)) / Settings.Graph.Intervals.X) - self.Axis.y.Position.X.Scale
	
	local yModifier = Settings.Graph.Intervals.Y * Offsets.Y.Start
	local yCorrection = ((yModifier - (Offsets.Y.Start - Offsets.Y.End)) / Settings.Graph.Intervals.Y) - Offsets.Y.Start
	
	local xFolder = Instance.new("Folder")
	xFolder.Name = "XIntervals"
	xFolder.Parent = GraphFrame
	
	--X Intervals	
	for intervalX = 1, Settings.Graph.Intervals.X-1 do 
		local interval = Instance.new("Frame")
		
		interval.BorderSizePixel = 0
		interval.BackgroundColor3 = Settings.Graph.Colors.Interval
		interval.Size = UDim2.new(0, 1.5, 1, 0)
		interval.Transparency = 0.7
		interval.ZIndex = 0 
		interval.Name = "X"..intervalX
		
		local xPosition = (intervalX - (Offsets.X.Start - Offsets.X.End)) / Settings.Graph.Intervals.X 
				
		interval.Position = UDim2.fromScale(
			xPosition - xCorrection,
			0
		)
		
		table.insert(self.Intervals, interval)
		
		interval.Parent = xFolder
	end
	
	local yFolder = Instance.new("Folder") 
	yFolder.Name = "YIntervals"
	yFolder.Parent = GraphFrame
	
	--Y Intervals
	for intervalY = 1, Settings.Graph.Intervals.Y-1 do
		local interval = Instance.new("Frame")
		
		interval.BorderSizePixel = 0
		interval.BackgroundColor3 = Settings.Graph.Colors.Interval
		interval.Size = UDim2.new(1, 0, 0, 1.5) 
		interval.Transparency = 0.7
		interval.ZIndex = 0
		interval.Name = "Y"..intervalY
		
		local yPosition = (intervalY - (Offsets.Y.Start - Offsets.Y.End)) / Settings.Graph.Intervals.Y
		
		interval.Position = UDim2.fromScale(
			0,
			yPosition - yCorrection
		)
		
		table.insert(self.Intervals, interval)
		
		interval.Parent = yFolder
	end
end

local function genPointTemplate()
	local template = Instance.new("Frame")
	
	template.Name = "2DPT" -- Abbrev. 2 Dimensional Point
	template.BorderSizePixel = 0
	template.Size = UDim2.fromOffset(table.unpack(Settings.Graph.Sizes.Point))
	template.ZIndex = 2
	
	return template
end

local function genLineTemplate()
	local template = Instance.new("Frame")
	
	template.Name = "2DLine"
	template.BorderSizePixel = 0
	template.ZIndex = 2
	
	return template
end

function Graph:RenderWaveform(display, features)		
	local templatePoint = genPointTemplate()
	templatePoint.BackgroundColor3 = display.Color 
	
	local pointFolder = Instance.new("Folder") 
	pointFolder.Parent = GraphFrame
	
	for x = 0, features.Period, features.Step do 
		local xPos = (((x / features.Period) * X_PC) - X_SC) + Offsets.X.Start
		local yPos = 1 - ((((features.Waveform(x) / features.YMax) * Y_PC) - Y_SC) + Offsets.Y.Start)
		
		if yPos <= 0 or yPos >= 1 then -- Point lying outside of frame... discard
			continue
		end
		
		local point = templatePoint:Clone()
		
		point.Position = UDim2.fromScale(xPos, yPos)
		point.Parent = pointFolder
	end
	
	-- Wave Naming / Storage
	
	local waveName = display.Name
	
	if self.Waveforms[waveName] then 
		-- Retry names until a unique one is found
		local waveIndex = 0
		while self.Waveforms[waveName..waveIndex] do 
			waveIndex += 1
		end
		waveName ..= waveIndex
	end
	
	pointFolder.Name = waveName
	self.Waveforms[waveName] = pointFolder
	
	-- Cleanup 
	
	templatePoint:Destroy()
	templatePoint = nil
end

return Graph
