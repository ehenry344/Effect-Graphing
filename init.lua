local Graph = require(script.Parent.Graph)

local newGraph = Graph.New(script.Parent.MainFrame.Graph)

newGraph:RenderWaveform(
	{ 
		Name = "Sine", 
		Color = Color3.fromRGB(85, 255, 127)
	},
	{
		Waveform = function(x)
			return math.sin(x)
		end,
		Period = math.pi * 2, 
		Step = math.pi / 200, 
		YMax = 4
	}
)

newGraph:RenderWaveform(
	{
		Name = "Cosine", 
		Color = Color3.fromRGB(238, 0, 255)
	},
	{
		Waveform = function(x)
			return math.cos(x)
		end,
		Period = math.pi * 12, 
		Step = math.pi / 1000, 
		YMax = 4
	}
)

newGraph:RenderWaveform(
	{
		Name = "StraightLine", 
		Color = Color3.fromRGB(255, 255, 0)
	}, 
	{
		Waveform = function(x)
			return x
		end,
		Period = math.pi * 2, 
		Step = math.pi / 200, 
		YMax = 10
	}
)
