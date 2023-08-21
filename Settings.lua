local Settings = {}

Settings.Graph = { 
	Offsets = { 
		X = { 
			Start = 0.05, 
			End = 0.2
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
		Axis = Color3.fromRGB(255, 255, 255), 
		Interval = Color3.fromRGB(89, 89, 89),
		PhaseIntervals = Color3.fromRGB(0, 85, 0)
	}, 
	
	Intervals = { 
		X = 20, 
		Y = 20
	},
	
	ShowAllBounds = true
}
return Settings
