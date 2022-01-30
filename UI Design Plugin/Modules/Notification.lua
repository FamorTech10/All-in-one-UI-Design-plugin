local UIs = script.Parent.Parent:WaitForChild("UIs")
local notigui = UIs:WaitForChild("Notification")

local notification = {}
notification.__index = notification

function notification.new(parent)
	local self = {}
	
	local root = notigui:Clone()
	root.Parent = parent
	
	self.root = root
	self.Tittle = root.TextLabel
	self.Accept = root.Accept
	self.Cancel = root.Cancel
	local Frame1 = {}
	
	Frame1.Bottom = root.Frame1.Bottom
	Frame1.Header = root.Frame1.Header
	Frame1.Space = root.Frame1.Space
	local Frame2 = {}

	Frame2.Bottom = root.Frame2.Bottom
	Frame2.Header = root.Frame2.Header
	Frame2.Space = root.Frame2.Space
	
	self.Frame1 = Frame1
	self.Frame2 = Frame2
	return setmetatable(self, notification)
end

function notification:WaitForAnswer()
	local answer = nil
	
	self.Accept.MouseButton1Click:Connect(function()
		if answer == nil then
			answer = true
		end
	end)
	self.Cancel.MouseButton1Click:Connect(function()
		if answer == nil then
			answer = false
		end
	end)
	
	while true do
		task.wait(.05)
		if answer ~= nil then
			return answer
		end
	end
end
return notification
