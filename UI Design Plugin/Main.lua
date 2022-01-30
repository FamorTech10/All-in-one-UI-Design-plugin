local toolbar = plugin:CreateToolbar("UI Tools")
local Selection = game:GetService("Selection")
local TweenService = game:GetService("TweenService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local UIs = script.Parent.UIs
local Modules = script.Parent.Modules
local gui = UIs.Gui

local UIclasses = require(Modules:WaitForChild("UIclasses"))
local Notifications = require(Modules:WaitForChild("Notification"))

--plugin
local ToolsButton = toolbar:CreateButton("Open ", "Open UI design tools", "rbxassetid://8678345796")
local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,  
	false,   
	true, 
	300,    
	500,  
	300,    
	500     
)
local widget  = plugin:CreateDockWidgetPluginGui("Widget", widgetInfo)
widget.Title = "Properties"
UIs.Gui.Parent = widget




-- Constants (for future customization)
local CORNER_RADIUS = 8
local FontColor = Color3.fromRGB(255,255,255)
local LightColor = Color3.fromRGB(56, 56, 56)
local SelectionColor = Color3.fromRGB(130,130,130)
local BackgroundColor = Color3.fromRGB(39, 39, 39)
local ValidInput = Color3.fromRGB(50,200,50)
local InvalidInput = Color3.fromRGB(200,50,50)
local ButtonColor = Color3.fromRGB(39,39,39)

-- variables (will be used better when i move into oop)

local selectedobj = nil
local currentpage = "Properties"
local Conections = {}
local selconnection = nil

--local functions
local function PropertyExists(obj, prop)
	return ({pcall(function()if(typeof(obj[prop])=="Instance")then error()end end)})[1]
end
local function StringFromUdim2(udim)
	local scalex = string.format("%.3f",udim.X.Scale)
	local offsetx = string.format("%.3f",udim.X.Offset)
	local scaley = string.format("%.3f",udim.Y.Scale)
	local offsety = string.format("%.3f",udim.Y.Offset)
	return string.format("{%.8g,%.8g},{%.8g,%.8g}",scalex,offsetx,scaley,offsety)
end
local function RoundNumber(number)
	--not really rounding, just for display
	return string.format("%.8g",string.format("%.2f",number))
end
local function StringFromColor3(color3)
	return string.format("%s,%s,%s",math.round(color3.R * 255),math.round(color3.G * 255),math.round(color3.B * 255))
end
local function UpdateGui(selectedobject)
	local data = gui.Properties
	data.Visible = true
	gui.Properties.TextProperties.Visible = false
	gui.Properties.ImageProperties.Visible = false
	data.TextboxProperties.Visible = false
	
	data.ObjectData.DataLabel.Text = string.format('%s "%s" ',selectedobject.ClassName,selectedobject.Name)
	-- transform
	data.Transform.Anchor_Point.TextBox.Text = tostring(selectedobject.AnchorPoint)
	data.Transform.PosFrame.TextBox.Text = StringFromUdim2(selectedobject.Position)
	data.Transform.SizeFrame.TextBox.Text = StringFromUdim2(selectedobject.Size)
	data.Transform.RotFrame.TextBox.Text = RoundNumber(selectedobject.Rotation)
	--Appearance
	data.Appearance.BGColor.TextBox.Text = StringFromColor3(selectedobject.BackgroundColor3)
	data.Appearance.BGColor.ColorView.Color.BackgroundColor3 = selectedobject.BackgroundColor3
	data.Appearance.Opacity.TextBox.Text = RoundNumber(selectedobject.BackgroundTransparency)
	data.Appearance.Stroke.TextBox.Text = RoundNumber(selectedobject.BorderSizePixel)
	data.Appearance.Stroke.ColorView.Color.BackgroundColor3 = selectedobject.BorderColor3
	--text
	if UIclasses[selectedobject.ClassName].Properties.Text then
		data.TextProperties.Visible = true
		data.TextProperties.Text.TextBox.Text = selectedobject.Text
		data.TextProperties.TextColor.TextBox.Text = StringFromColor3(selectedobject.TextColor3)
		data.TextProperties.TextColor.ColorView.Color.BackgroundColor3 = selectedobject.TextColor3
		data.TextProperties.TextSize.TextBox.Text = selectedobject.TextSize
		data.TextProperties.TextTransparency.TextBox.Text = selectedobject.TextTransparency
		if selectedobject.TextScaled then
			data.TextProperties.TextScaled.Button.Scaledbtn.ImageTransparency = 0
		else
			data.TextProperties.TextScaled.Button.Scaledbtn.ImageTransparency = 1
		end
	end
	--image
	if UIclasses[selectedobject.ClassName].Properties.Image then
		data.ImageProperties.Visible = true
		data.ImageProperties.Image.TextBox.Text = tostring(selectedobject.Image)
		data.ImageProperties.ImageColor.TextBox.Text = StringFromColor3(selectedobject.ImageColor3)
		data.ImageProperties.ImageColor.ColorView.Color.BackgroundColor3 = selectedobject.ImageColor3
		data.ImageProperties.ImageTransparency.TextBox.Text = selectedobject.ImageTransparency
	end
	--textbox
	if UIclasses[selectedobject.ClassName].Properties.Box then
		data.TextboxProperties.Visible = true
		data.TextboxProperties.Placeholdertext.TextBox.Text = selectedobject.PlaceholderText
		data.TextboxProperties.TextColor.TextBox.Text = StringFromColor3(selectedobject.PlaceholderColor3)
		data.TextboxProperties.TextColor.ColorView.Color.BackgroundColor3 = selectedobject.PlaceholderColor3
		if selectedobject.MultiLine then
			data.TextboxProperties.Multiline.Button.Scaledbtn.ImageTransparency = 0
		else
			data.TextboxProperties.Multiline.Button.Scaledbtn.ImageTransparency = 1
		end
		if selectedobject.ClearTextOnFocus then
			data.TextboxProperties.ClearTextOnFocus.Button.Scaledbtn.ImageTransparency = 0
		else
			data.TextboxProperties.ClearTextOnFocus.Button.Scaledbtn.ImageTransparency = 1
		end
	end
end



-- functions for buttons
local QuickActions = {}
function QuickActions.FitParent()
	for _, v in pairs(Selection:Get()) do
		v.Size = UDim2.new(1,0,1,0)
		v.AnchorPoint = Vector2.new(.5,.5)
		v.Position = UDim2.new(.5,0,.5,0)
	end
	ChangeHistoryService:SetWaypoint("FitParent Function")
end
function QuickActions.RemoveBorders()
	if selectedobj:FindFirstChildWhichIsA("UICorner") then return end
	local frame = gui.NotificationFrame
	local notification = Notifications.new(gui)
	local selobj = selectedobj
	
	for _,v in pairs(Conections) do
		v:Disconnect()
	end
	
	notification.Tittle.Text = "Add UICorner"
	notification.Frame1.Header.Text = "Scale"
	notification.Frame1.Bottom.Visible = false

	local txtbox1 = UIs.Resources.TextBox:Clone()
	txtbox1.Text = "0"
	txtbox1.Parent = notification.Frame1.Space
	
	local txtbox2 = UIs.Resources.TextBox:Clone()
	txtbox2.Text = CORNER_RADIUS
	txtbox2.Parent = notification.Frame2.Space
	
	
	notification.Frame2.Header.Text = "Offset"
	notification.Frame2.Bottom.Visible = false
	
	local scale = 0
	local offset = 0
	txtbox1.Focused:Connect(function()
		txtbox1.FocusLost:Connect(function(enterpressed)
			if tonumber(txtbox1.Text) ~= nil then
				scale = tonumber(txtbox1.Text)
				txtbox1.UIStroke.Color = ValidInput
			else	
				scale = 0
				txtbox1.UIStroke.Color = InvalidInput
			end
		end)
	end)
	txtbox2.Focused:Connect(function()
		txtbox2.FocusLost:Connect(function(enterpressed)
			if tonumber(txtbox2.Text) ~= nil then
				offset = math.ceil(tonumber(txtbox2.Text))
				txtbox2.Text = offset
				txtbox2.UIStroke.Color = ValidInput
			else	
				offset = 0
				txtbox2.UIStroke.Color = InvalidInput
			end
		end)
		
	end)
	
	notification.root.Visible = true
	TweenService:Create(frame,TweenInfo.new(.25),{BackgroundTransparency = .2}):Play()

	local answer = notification:WaitForAnswer()
	
	if answer == true then
		local border = Instance.new("UICorner")
		border.CornerRadius = UDim.new(scale,offset)
		border.Parent = selectedobj
	end
	
	notification.root:Destroy()
	TweenService:Create(frame,TweenInfo.new(.25),{BackgroundTransparency = 1}):Play()

	ConnectCurrentPage()
	ChangeHistoryService:SetWaypoint("RemoveBorders Function")
end
function QuickActions.empty()
	print("nothing here")
end
function QuickActions.Convert()
	local frame = gui.NotificationFrame
	local notification = Notifications.new(gui)
	local selobj = selectedobj
	local index = 1
	
	
	local classes = {}
	for i, v in pairs(UIclasses) do
		table.insert(classes,v)
	end
	
	--disconnect events
	
	for _,v in pairs(Conections) do
		v:Disconnect()
	end
	
	--change values
	notification.Tittle.Text = "Convert Object"
	notification.Frame1.Header.Text = "From"
	notification.Frame1.Bottom.Text = selobj.ClassName
	
	local img1 = UIs.Resources.ImageLabel:Clone()
	img1.Parent = notification.Frame1.Space
	img1.Image = UIclasses[selobj.ClassName].Icon
	
	notification.Frame2.Header.Text = "To"
	notification.Frame2.Bottom.Text = classes[index].ClassName

	local img2 = UIs.Resources.ImageButton:Clone()
	img2.Parent = notification.Frame2.Space
	img2.Image = classes[index].Icon
	
	img2.MouseButton1Click:Connect(function()
		index += 1
		if index > 7 then index = 1 end
		
		img2.Image = classes[index].Icon
		notification.Frame2.Bottom.Text = classes[index].ClassName
	end)
	
	
	--visibility
	notification.root.Visible = true
	TweenService:Create(frame,TweenInfo.new(.25),{BackgroundTransparency = .2}):Play()

	local answer = notification:WaitForAnswer()
	
	if answer == true then
		--convert
		local properties = UIclasses[selobj.ClassName].Properties
		local newobject = Instance.new(classes[index].ClassName)

		for class, v in pairs(classes[index].Properties) do
			if properties[class] then
				for name, value in pairs(v) do
					newobject[name] = selectedobj[name]
				end
			end
		end

		newobject.Parent = selobj.Parent
		for _, v in pairs(selobj:GetChildren()) do
			v.Parent = newobject
		end

		selobj:Destroy()
		Selection:Set({newobject})
		selectedobj = newobject
		UpdateGui(selectedobj)
	end
	notification.root:Destroy()
	TweenService:Create(frame,TweenInfo.new(.25),{BackgroundTransparency = 1}):Play()

	ConnectCurrentPage()
	ChangeHistoryService:SetWaypoint("Convert Function")
end
function QuickActions.ScaleText()
	for _, v in ipairs(Selection:Get()) do
		if PropertyExists(v, "TextScaled") and not v:FindFirstChildWhichIsA("UITextSizeConstraint") then
			if v.TextScaled == false then
				local scale = Instance.new("UITextSizeConstraint")
				scale.MaxTextSize = v.TextSize
				scale.Parent = v
				v.TextScaled = true
			elseif v.TextScaled == true then
				local textconstraint = Instance.new("UITextSizeConstraint")
				textconstraint.MaxTextSize = v.TextBounds.Y
				textconstraint.Parent = v				
			end
		end
	end
	ChangeHistoryService:SetWaypoint("Text Scaled")
end
local frame = Instance.new("TextButton")

--methods for whenever i move into OOP
function HandleErrors(errormsg)
	print(errormsg)
end
function PropertiesConections()
	local Properties = gui.Properties
	local buttons = {}
	local singlebuttons = {}
	--textbox
	for _, descendant in pairs(Properties:GetDescendants()) do
		if descendant:IsA("TextBox") then
			--textbox gained focus
			local connection = descendant.Focused:Connect(function()
				--connect the focuslost event
				local text = descendant.Text
				local con
				con = descendant.FocusLost:Connect(function(enterPressed,input)
					if enterPressed then
						--checks value type
						local valuetype = descendant.Parent.ValueType.Value
						local propertyname = descendant.Parent.PropertyName.Value
						local inputvalue = nil
						--logic based on valuetype
						if valuetype == "UDim2" then
							--get the numbers
							local tmp = string.gsub(descendant.Text,"{","")
							local finaltbl = string.split(string.gsub(tmp,"}",""),",")

							local success, errormsg = pcall(function()
								inputvalue = UDim2.new(finaltbl[1],finaltbl[2],finaltbl[3],finaltbl[4])
							end)
							if not success then
								HandleErrors(errormsg)
								descendant.Text = text
								con:Disconnect()
								return
							end
						elseif valuetype == "Vector2" then
							local finaltbl = string.split(string.gsub(descendant.Text," ",""),",")
							local success, errormsg = pcall(function()
								inputvalue = Vector2.new(finaltbl[1],finaltbl[2])
							end)
							if not success then
								HandleErrors(errormsg)
								descendant.Text = text
								con:Disconnect()
								return
							end
						elseif valuetype == "Int" then
							inputvalue = tonumber(descendant.Text)
							if inputvalue == nil then
								HandleErrors("Input is not valid")
								descendant.Text = text
								con:Disconnect()
								return
							end
						elseif valuetype == "Color3" then
							local text = string.gsub(descendant.Text," ","")
							local colors = string.split(text,",")
							
							local numbers = {}
							for _, v in ipairs(colors) do
								local number = tonumber(v)
								if number == nil then
									HandleErrors("Invalid input")
									return
								else
									table.insert(numbers,number)
								end
							end							
							inputvalue = Color3.fromRGB(numbers[1],numbers[2],numbers[3])
						elseif valuetype == "String" then
							inputvalue = descendant.Text
						
							
						end
						
						selectedobj[propertyname] = inputvalue
						ChangeHistoryService:SetWaypoint("Changed a property")
						con:Disconnect()
					else
						descendant.Text = text
						con:Disconnect()
					end

				end)
			end)
			table.insert(Conections,connection)
		end
	end
	
	--single buttons
	
	table.insert(singlebuttons,Properties.TextProperties.TextScaled.Button.Scaledbtn)
	table.insert(singlebuttons,Properties.TextboxProperties.Multiline.Button.Scaledbtn)
	table.insert(singlebuttons,Properties.TextboxProperties.ClearTextOnFocus.Button.Scaledbtn)
	
	local con1 = Properties.Appearance.Opacity.ToggleVisible.Button.MouseButton1Click:Connect(function()
		selectedobj.Visible = not selectedobj.Visible
	end)
	table.insert(Conections,con1)
	for _, v in pairs(singlebuttons) do
		local con = v.MouseButton1Click:Connect(function()
			local prop = v.Parent.Parent.PropertyName.Value
			selectedobj[prop] = not selectedobj[prop]
		end)
		table.insert(Conections,con)	
	end
	
	--align properties
	for _, button in pairs(Properties.Align:GetChildren()) do
		if button:IsA("ImageButton") then

			local connection = button.MouseButton1Click:Connect(function()	
				local axis 				
				if string.find(button.Name,"X") ~= nil then
					axis = "X"
				else
					axis = "Y"
				end
				for _, v in pairs(game.Selection:Get()) do
					local abssize = v.Parent.AbsoluteSize[axis]
					local pos = button.Pos.Value

					local position = (abssize - v.AbsoluteSize[axis]) * pos
					position = position + v.AbsoluteSize[axis] * v.AnchorPoint[axis]

					local scale = position / abssize
					
					if axis == "X" then
						v.Position = UDim2.new(scale,0,v.Position.Y.Scale,v.Position.Y.Offset)
					else
						v.Position = UDim2.new(v.Position.X.Scale,v.Position.X.Offset,scale,0)
					end
				end
				ChangeHistoryService:SetWaypoint("Aligned")
				UpdateGui(selectedobj)			
			end)
			table.insert(Conections,connection)	
		end
	end	

	-- quick actions
	for _, button in pairs(Properties.QuickActions:GetChildren()) do
		if button:IsA("TextButton") then
			local connection = button.MouseButton1Click:Connect(QuickActions[button.Name])
			table.insert(Conections,connection)	
			table.insert(buttons,button)
		end
	end
	
	for _, v in pairs(buttons) do
		local con1 = v.MouseEnter:Connect(function()
			TweenService:Create(v,TweenInfo.new(.25),{BackgroundColor3 = SelectionColor}):Play()
		end)
		local con2 = v.MouseLeave:Connect(function()
			TweenService:Create(v,TweenInfo.new(.25),{BackgroundColor3 = ButtonColor}):Play()
		end)
	end
end
function ToolsConections()
	local Tools = gui.Tools
	local buttons = {}
	
	--unit convertion
	for _, button in pairs(Tools.UnitConvertion:GetChildren()) do
		if button:IsA("TextButton") then
			local connection = button.MouseButton1Click:Connect(function()				
				local tbl = string.split(button.Name,"_")
				local value

				if tbl[2] == "Position" then
					if tbl[1] == "Scale" then
						for _, v in pairs(game.Selection:Get()) do
							if v:isA("GuiBase2d") and v.Parent and PropertyExists(v,"Position") then
								if PropertyExists(v.Parent, "AbsoluteSize") then
									local ScaleXPos = v.Position.X.Offset/v.Parent.AbsoluteSize.X + v.Position.X.Scale
									local ScaleYPos = v.Position.Y.Offset/v.Parent.AbsoluteSize.Y  + v.Position.Y.Scale
									v.Position = UDim2.new(ScaleXPos, 0, ScaleYPos, 0)
								end
							end
						end		
					else
						for _, v in pairs(game.Selection:Get()) do
							if v:isA("GuiBase2d") and v.Parent and PropertyExists(v, "Position") then
								if  PropertyExists(v.Parent, "AbsoluteSize") then
									local OffsetXPos = v.Position.X.Scale*v.Parent.AbsoluteSize.X + v.Position.X.Offset
									local OffsetYPos = v.Position.Y.Scale*v.Parent.AbsoluteSize.Y + v.Position.Y.Offset
									v.Position = UDim2.new(0, OffsetXPos, 0, OffsetYPos)
								end	
							end
						end
					end

				else
					if tbl[1] == "Scale" then
						for _, v in pairs(game.Selection:Get()) do
							if v:isA("GuiBase2d") and PropertyExists(v, "Size") and not v.Parent:IsA("ScrollingFrame") then
								local Viewport_Size

								if PropertyExists(v.Parent, "AbsoluteSize") then
									Viewport_Size = v.Parent.AbsoluteSize
								elseif v:FindFirstAncestorWhichIsA("GuiObject") and PropertyExists(v:FindFirstAncestorWhichIsA("GuiObject"), "AbsoluteSize") then
									Viewport_Size = v:FindFirstAncestorWhichIsA("GuiObject").AbsoluteSize
								else
									Viewport_Size = workspace.CurrentCamera.ViewportSize
								end

								local LB_Size = v.AbsoluteSize
								v.Size = UDim2.new(LB_Size.X/Viewport_Size.X,0,LB_Size.Y/Viewport_Size.Y, 0)
							end
						end
					else
						for _, v in pairs(game.Selection:Get()) do
							if v:isA("GuiBase2d") and PropertyExists(v, "Size")then
								local LB_Size = v.AbsoluteSize
								v.Size = UDim2.new(0, LB_Size.X, 0, LB_Size.Y)
							end
						end
					end
				end

				UpdateGui(selectedobj)			
				ChangeHistoryService:SetWaypoint("Unit Conversion")
			end)
			table.insert(Conections,connection)	
			table.insert(buttons,button)
		end
	end
	
	for _, v in pairs(buttons) do
		local con1 = v.MouseEnter:Connect(function()
			TweenService:Create(v,TweenInfo.new(.25),{BackgroundColor3 = SelectionColor}):Play()
		end)
		local con2 = v.MouseLeave:Connect(function()
			TweenService:Create(v,TweenInfo.new(.25),{BackgroundColor3 = ButtonColor}):Play()
		end)
	end
end
function ConnectCurrentPage()
	if currentpage == "Properties" then
		PropertiesConections()
	elseif currentpage == "Tools" then
		ToolsConections()
	end
end
local function UpdateSelection()
	local selectedobjects = Selection:Get()
	local selectedobject
	
	if #selectedobjects == 0 then
		gui.Properties.Visible = false
	elseif #selectedobjects > 0 then
		selectedobject = selectedobjects[1]

		if selectedobject then
			if selectedobject:IsA("GuiObject") then
				--class and name 
				UpdateGui(selectedobject)
				selectedobj = selectedobject			
				selectedobj.Changed:Connect(function()
					UpdateGui(selectedobj)
				end)
			else
				gui.Properties.Visible = false
			end
		end

			
		end
	
	return selectedobject
end


local function ChangePage(page)
	if currentpage ~= page then
		local current = gui:FindFirstChild(currentpage)
		if current then
			--visibility
			current.Visible = false
			-- disconnect events 
			for _,v in pairs(Conections) do
				v:Disconnect()
			end
			
			if selectedobj then
				gui:FindFirstChild(page).Visible = true
			end
			
			--color
			gui.Options:FindFirstChild(currentpage).BackgroundColor3 = BackgroundColor
			gui.Options:FindFirstChild(page).BackgroundColor3 = LightColor
			
			
			
			currentpage = page
			widget.Title = currentpage
			ConnectCurrentPage()
		end
	end
end
local function OpenGui()
	widget.Enabled = not widget.Enabled
	if widget.Enabled  then
		UpdateSelection()
		
		
		-- change page
		for _,v in pairs(gui.Options:GetChildren()) do
			if v:IsA("TextButton") then
				v.MouseButton1Click:Connect(function()
					ChangePage(v.Name)
				end)
			end
		end
		
		ConnectCurrentPage()
		
		selconnection = Selection.SelectionChanged:Connect(UpdateSelection)
	else
		if selconnection then selconnection:Disconnect() end
	end
	
	
end
ToolsButton.Click:Connect(OpenGui)
