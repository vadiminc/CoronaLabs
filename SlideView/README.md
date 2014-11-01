Slide View v 1.1
- added external listerner
- you can add any display objects

Demo code:

```
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
```