-- 
-- Abstract: SlideView sample app
-- Version: 1.1 Modified by Vadim.Inc
-- 

display.setStatusBar( display.HiddenStatusBar ) 

local slideView = require("slideView")
	
local function mySlideListener(event)
	print("Action:", event.phase, "Current Slide:", event.slide)
end

-- you can add any display object or display group
local mySlides = {
	display.newRect( 0, 0, 150, 250 ), 
	display.newRect( 0, 0, 50, 50 ),
	display.newRect( 0, 0, 200, 200 ),
	display.newRect( 0, 0, 80, 150 )
}		

local slidesPanel = slideView.new( mySlides, mySlideListener )
-- slidesPanel is a display.Group. you can change any display params like x,y,alpha and so on