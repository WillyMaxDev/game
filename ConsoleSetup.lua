local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PLOT_POSITIONS = {
	[1] = {pos = Vector3.new(263.075, 287.454, -4.067), ori = Vector3.new(0, 0, 0)},
	[2] = {pos = Vector3.new(260.766, 287.454, 54.503), ori = Vector3.new(0, 180, 0)},
	[3] = {pos = Vector3.new(134.077, 287.454, -4.067), ori = Vector3.new(0, 0, 0)},
	[4] = {pos = Vector3.new(131.766, 287.454, 54.503), ori = Vector3.new(0, 180, 0)},
	[5] = {pos = Vector3.new(392.075, 287.454, -4.067), ori = Vector3.new(0, 0, 0)},
	[6] = {pos = Vector3.new(389.766, 287.454, 54.503), ori = Vector3.new(0, 180, 0)}
}

local PLOT_ORDER = {"1", "2", "3", "4", "5", "6"}

local function FindAvailablePlot()
	local plotsFolder = game.Workspace:FindFirstChild("Plots")
	if not plotsFolder then
		return 1
	end
	
	for _, plotNum in ipairs(PLOT_ORDER) do
		local exists = false
		for _, child in ipairs(plotsFolder:GetChildren()) do
			if child.Name ~= "EmptyPlot" and child:FindFirstChild("PrimaryPart") then
				exists = true
				break
			end
		end
		if not exists then
			return tonumber(plotNum)
		end
	end
	return nil
end

local function MoveEmptyPlotToStorage(plotNum)
	local plotsFolder = game.Workspace:FindFirstChild("Plots")
	if not plotsFolder then return end
	
	local emptyPlots = {}
	for _, child in ipairs(plotsFolder:GetChildren()) do
		if child.Name == "EmptyPlot" then
			table.insert(emptyPlots, child)
		end
	end
	
	if #emptyPlots > 0 then
		local closestEmpty = emptyPlots[1]
		local plotPos = PLOT_POSITIONS[plotNum].pos
		local minDist = (closestEmpty:GetPrimaryPartCFrame().Position - plotPos).Magnitude
		
		for i = 2, #emptyPlots do
			local dist = (emptyPlots[i]:GetPrimaryPartCFrame().Position - plotPos).Magnitude
			if dist < minDist then
				minDist = dist
				closestEmpty = emptyPlots[i]
			end
		end
		
		closestEmpty.Parent = nil
	end
end

local function CreatePlayerPlot(player)
	local plotNum = FindAvailablePlot()
	if not plotNum then
		warn("No plots available for player " .. player.Name)
		return
	end
	
	MoveEmptyPlotToStorage(plotNum)
	
	local mainPlot = game.ReplicatedStorage:FindFirstChild("Storage"):FindFirstChild("MainPlot")
	if not mainPlot then
		warn("MainPlot not found in ReplicatedStorage.Storage")
		return
	end
	
	local newPlot = mainPlot:Clone()
	newPlot.Name = player.Name
	
	local plotsFolder = game.Workspace:FindFirstChild("Plots")
	if not plotsFolder then
		plotsFolder = Instance.new("Folder")
		plotsFolder.Name = "Plots"
		plotsFolder.Parent = game.Workspace
	end
	
	newPlot.Parent = plotsFolder
	
	local plotData = PLOT_POSITIONS[plotNum]
	local cf = CFrame.new(plotData.pos) * CFrame.Angles(
		math.rad(plotData.ori.X),
		math.rad(plotData.ori.Y),
		math.rad(plotData.ori.Z)
	)
	
	if newPlot:FindFirstChild("PrimaryPart") then
		newPlot:SetPrimaryPartCFrame(cf)
	else
		for _, part in ipairs(newPlot:GetDescendants()) do
			if part:IsA("BasePart") then
				newPlot.PrimaryPart = part
				newPlot:SetPrimaryPartCFrame(cf)
				break
			end
		end
	end
	
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character:MoveTo(PLOT_POSITIONS[plotNum].pos + Vector3.new(0, 5, 0))
	end
end

local function CreateServerScripts()
	local serverScriptService = game:GetService("ServerScriptService")
	
	local existingPlotScript = serverScriptService:FindFirstChild("PlotSystemServer")
	if existingPlotScript then
		existingPlotScript:Destroy()
	end
	
	local plotScript = Instance.new("LocalScript")
	plotScript.Name = "PlotSystemServer"
	plotScript.Source = [[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PLOT_POSITIONS = {
	[1] = {pos = Vector3.new(263.075, 287.454, -4.067), ori = Vector3.new(0, 0, 0)},
	[2] = {pos = Vector3.new(260.766, 287.454, 54.503), ori = Vector3.new(0, 180, 0)},
	[3] = {pos = Vector3.new(134.077, 287.454, -4.067), ori = Vector3.new(0, 0, 0)},
	[4] = {pos = Vector3.new(131.766, 287.454, 54.503), ori = Vector3.new(0, 180, 0)},
	[5] = {pos = Vector3.new(392.075, 287.454, -4.067), ori = Vector3.new(0, 0, 0)},
	[6] = {pos = Vector3.new(389.766, 287.454, 54.503), ori = Vector3.new(0, 180, 0)}
}

local PLOT_ORDER = {"1", "2", "3", "4", "5", "6"}

local function FindAvailablePlot()
	local plotsFolder = game.Workspace:FindFirstChild("Plots")
	if not plotsFolder then
		return 1
	end
	
	local occupied = {}
	for _, child in ipairs(plotsFolder:GetChildren()) do
		if child.Name ~= "EmptyPlot" then
			table.insert(occupied, child.Name)
		end
	end
	
	for _, plotNum in ipairs(PLOT_ORDER) do
		local found = false
		for _, occupiedName in ipairs(occupied) do
			if occupiedName == plotNum then
				found = true
				break
			end
		end
		if not found then
			return tonumber(plotNum)
		end
	end
	return nil
end

local function MoveEmptyPlotToStorage(plotNum)
	local plotsFolder = game.Workspace:FindFirstChild("Plots")
	if not plotsFolder then return end
	
	local emptyPlots = {}
	for _, child in ipairs(plotsFolder:GetChildren()) do
		if child.Name == "EmptyPlot" then
			table.insert(emptyPlots, child)
		end
	end
	
	if #emptyPlots > 0 then
		local closestEmpty = emptyPlots[1]
		local plotPos = PLOT_POSITIONS[plotNum].pos
		local minDist = (closestEmpty:GetPrimaryPartCFrame().Position - plotPos).Magnitude
		
		for i = 2, #emptyPlots do
			local dist = (emptyPlots[i]:GetPrimaryPartCFrame().Position - plotPos).Magnitude
			if dist < minDist then
				minDist = dist
				closestEmpty = emptyPlots[i]
			end
		end
		
		closestEmpty.Parent = nil
	end
end

local function CreatePlayerPlot(player)
	local plotNum = FindAvailablePlot()
	if not plotNum then
		warn("No plots available for player " .. player.Name)
		return
	end
	
	MoveEmptyPlotToStorage(plotNum)
	
	local mainPlot = game.ReplicatedStorage:FindFirstChild("Storage"):FindFirstChild("MainPlot")
	if not mainPlot then
		warn("MainPlot not found in ReplicatedStorage.Storage")
		return
	end
	
	local newPlot = mainPlot:Clone()
	newPlot.Name = player.Name
	
	local plotsFolder = game.Workspace:FindFirstChild("Plots")
	if not plotsFolder then
		plotsFolder = Instance.new("Folder")
		plotsFolder.Name = "Plots"
		plotsFolder.Parent = game.Workspace
	end
	
	newPlot.Parent = plotsFolder
	
	local plotData = PLOT_POSITIONS[plotNum]
	local cf = CFrame.new(plotData.pos) * CFrame.Angles(
		math.rad(plotData.ori.X),
		math.rad(plotData.ori.Y),
		math.rad(plotData.ori.Z)
	)
	
	if newPlot:FindFirstChild("PrimaryPart") then
		newPlot:SetPrimaryPartCFrame(cf)
	else
		for _, part in ipairs(newPlot:GetDescendants()) do
			if part:IsA("BasePart") then
				newPlot.PrimaryPart = part
				newPlot:SetPrimaryPartCFrame(cf)
				break
			end
		end
	end
	
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character:MoveTo(PLOT_POSITIONS[plotNum].pos + Vector3.new(0, 5, 0))
	end
end

Players.PlayerAdded:Connect(CreatePlayerPlot)

for _, player in ipairs(Players:GetPlayers()) do
	CreatePlayerPlot(player)
end
]]
	plotScript.Parent = serverScriptService
end

CreateServerScripts()

Players.PlayerAdded:Connect(CreatePlayerPlot)

for _, player in ipairs(Players:GetPlayers()) do
	CreatePlayerPlot(player)
end

print("Sistema de Plots inicializado correctamente")
