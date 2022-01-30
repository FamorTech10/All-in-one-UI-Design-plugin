local properties = {
	GuiObject = {
		Archivable = 0,
		Active = 0,
		AnchorPoint = 0,
		AutomaticSize = 0,
		BackgroundColor3 = 0,
		BackgroundTransparency = 0,
		BorderColor3 = 0,
		BorderMode = 0,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Name = 0,
		Parent = 0,
		Position = 0,
		Rotation = 0,
		Selectable = 0,
		Size = 0,
		SizeConstraint = 0,
		--Style = 0,
		Visible = 0,
		ZIndex = 0,
		ClipsDescendants = 0,
		AutoLocalize = 0
	},
	ScrollingFrame = {
		AutomaticCanvasSize = 0,
		BottomImage = 0,
		CanvasSize = 0,
		ElasticBehavior = 0,
		HorizontalScrollBarInset = 0,
		MidImage = 0,
		ScrollBarImageColor3 = 0,
		ScrollBarImageTransparency = 0,
		ScrollBarImageThickness = 0,
		ScrollingDirection = 0,
		ScrollingEnabled = 0,
		TopImage = 0,
		VerticalScrollBarInset = 0,
		VerticalScrollBarPosition = 0
	},
	Text = {
		Font = 0,
		LineHeight = 0,
		MaxVisibleGraphemes = 0,
		RichText = 0,
		Text = 0,
		TextColor3 = 0,
		TextScaled = 0,
		TextSize = 0,
		TextStrokeColor3 = 0,
		TextStrokeTransparency = 0,
		TextTransparency = 0,
		TextTruncate = 0,
		TextWrapped = 0,
		TextXAlignment = 0,
		TextYAlignment = 0,
	},
	Image = {
		HoverImage = 0,
		Image = 0,
		ImageColor3 = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		ImageTransparency = 0,
		PressedImage = 0,
		ResampleMode = 0,
		ScaleType = 0,
		SliceScale = 0
	},
	Button = {
		AutoButtonColor = 0,
		Selected = 0
	},
	Box = {
		ClearTextOnFocus = 0,
		MultiLine = 0,
		PlaceholderColor3 = 0,
		PlaceholderText =0,
		SelectionStart = 0,
		ShowNativeInput = 0,
		TextEditable = 0,


	}
}

local UIclasses = {
	Frame = {
		Icon = "rbxassetid://8665777315",
		ClassName = "Frame",
		Properties = {
			Frame = properties.GuiObject
		}
	},
	ScrollingFrame = {
		Icon = "rbxassetid://8665777315",
		ClassName = "ScrollingFrame",
		Properties = {
			Frame = properties.GuiObject,
			ScrollingFrame = properties.ScrollingFrame
		}
	},
	TextLabel = {
		Icon = "rbxassetid://8665776449",
		ClassName = "TextLabel",
		Properties = {
			Frame = properties.GuiObject,
			Text = properties.Text
		}
	},
	TextButton = {
		Icon = "rbxassetid://8665776602",
		ClassName = "TextButton",
		Properties = {
			Frame = properties.GuiObject,
			Text = properties.Text,
			Button = properties.Button
		}
	},
	TextBox = {
		Icon = "rbxassetid://8665776602",
		ClassName = "TextBox",
		Properties = {
			Frame = properties.GuiObject,
			Text = properties.Text,
			Box = properties.Box
		}
	},
	ImageLabel = {
		Icon = "rbxassetid://8665776899",
		ClassName = "ImageLabel",
		Properties = {
			Frame = properties.GuiObject,
			Image =properties.Image
		}
	},
	ImageButton = {
		Icon = "rbxassetid://8665777085",
		ClassName = "ImageButton",
		Properties = {
			Frame =properties.GuiObject,
			Image = properties.Image,
			Button = properties.Button
		}
	},
}

return UIclasses