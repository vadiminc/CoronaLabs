-- slideView.lua
-- Modified by Vadim.Inc
-- v 1.1

SlideView = {}
SlideView.__index = SlideView

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local imgNum = nil
local images = nil
local background
local imageNumberText, imageNumberTextShadow

function SlideView.new( slideSet, callback, slideBackground, top, bottom )	
	local pad = 20
	local top = top or 0 
	local bottom = bottom or 0

	local g = display.newGroup()
		
	if slideBackground then
		background = display.newImage(slideBackground, 0, 0, true)
	else
		background = display.newRect( 0, 0, screenW, screenH-(top+bottom) )

		-- set anchors on the background
		background.anchorX = 0
		background.anchorY = 0

		background:setFillColor(0, 0, 0)
	end
	g:insert(background)
	
	slides = {}

	local function setSlideNumber()
		print("setSlideNumber", slideNum .. " of " .. #slides)
		imageNumberText.text = slideNum .. " of " .. #slides
		imageNumberTextShadow.text = slideNum .. " of " .. #slides
	end
	
	local function initSlide(num)
		if (num < #slides) then
			slides[num+1].x = screenW*1.5 + pad			
		end
		if (num > 1) then
			slides[num-1].x = (screenW*.5 + pad)*-1
		end
		setSlideNumber()
	end
	
	local function cancelTween()
		if prevTween then 
			transition.cancel(prevTween)
		end
		prevTween = tween 
	end
	
	local function nextSlide()
		tween = transition.to( slides[slideNum], {time=400, x=(screenW*.5 + pad)*-1, transition=easing.outExpo } )
		tween = transition.to( slides[slideNum+1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		slideNum = slideNum + 1
		initSlide(slideNum)
		callback({phase = "next", slide = slideNum})
	end
	
	local function prevSlide()
		tween = transition.to( slides[slideNum], {time=400, x=screenW*1.5+pad, transition=easing.outExpo } )
		tween = transition.to( slides[slideNum-1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		slideNum = slideNum - 1
		initSlide(slideNum)
		callback({phase = "prev", slide = slideNum})
	end
	
	local function cancelMove()
		tween = transition.to( slides[slideNum], {time=400, x=screenW*.5, transition=easing.outExpo } )
		tween = transition.to( slides[slideNum-1], {time=400, x=(screenW*.5 + pad)*-1, transition=easing.outExpo } )
		tween = transition.to( slides[slideNum+1], {time=400, x=screenW*1.5+pad, transition=easing.outExpo } )
	end


	for i = 1,#slideSet do
		local p = slideSet[i]
		local h = viewableScreenH-(top+bottom)
		if p.width > viewableScreenW or p.height > h then
			if p.width/viewableScreenW > p.height/h then 
					p.xScale = viewableScreenW/p.width
					p.yScale = viewableScreenW/p.width
			else
					p.xScale = h/p.height
					p.yScale = h/p.height
			end		 
		end
		g:insert(p)
	    
		if (i > 1) then
			p.x = screenW*1.5 + pad -- all slides offscreen except the first one
		else 
			p.x = screenW*.5
		end
		
		p.y = h*.5

		slides[i] = p
	end
	
	local defaultString = "1 of " .. #slides

	local navBar = display.newGroup()
	g:insert(navBar)
	
	local navBarGraphic = display.newImage("navBar.png", 0, 0, false)
	navBar:insert(navBarGraphic)
	navBarGraphic.x = viewableScreenW*.5
	navBarGraphic.y = 0
			
	imageNumberText = display.newText(defaultString, 0, 0, native.systemFontBold, 14)
	imageNumberText:setFillColor(1, 1, 1)
	imageNumberTextShadow = display.newText(defaultString, 0, 0, native.systemFontBold, 14)
	imageNumberTextShadow:setFillColor(0, 0, 0)
	navBar:insert(imageNumberTextShadow)
	navBar:insert(imageNumberText)
	imageNumberText.x = navBar.width*.5
	imageNumberText.y = navBarGraphic.y
	imageNumberTextShadow.x = imageNumberText.x - 1
	imageNumberTextShadow.y = imageNumberText.y - 1
	
	navBar.y = math.floor(navBar.height*0.5)

	slideNum = 1
	
	g.x = 0
	g.y = top + display.screenOriginY
			
	local function touchListener (self, touch) 
		local phase = touch.phase
		if ( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the contentBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true

			startPos = touch.x
			prevPos = touch.x
			
			transition.to( navBar,  { time=200, alpha=math.abs(navBar.alpha-1) } )
									
        elseif( self.isFocus ) then
        
			if ( phase == "moved" ) then
			
				transition.to(navBar,  { time=400, alpha=0 } )
						
				if tween then transition.cancel(tween) end
	
				local delta = touch.x - prevPos
				prevPos = touch.x
				
				slides[slideNum].x = slides[slideNum].x + delta
				
				if (slides[slideNum-1]) then
					slides[slideNum-1].x = slides[slideNum-1].x + delta
				end
				
				if (slides[slideNum+1]) then
					slides[slideNum+1].x = slides[slideNum+1].x + delta
				end

			elseif ( phase == "ended" or phase == "cancelled" ) then
				
				dragDistance = touch.x - startPos
				
				if (dragDistance < -40 and slideNum < #slides) then
					nextSlide()
				elseif (dragDistance > 40 and slideNum > 1) then
					prevSlide()
				else
					cancelMove()
				end
									
				if ( phase == "cancelled" ) then		
					cancelMove()
				end

				if (startPos - prevPos) < 5 and (startPos - prevPos) > -5 then
					callback({phase = "touched", slide = slideNum})
				end

                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
			end
		end
					
		return true
		
	end


	background.touch = touchListener
	background:addEventListener( "touch", background )

	------------------------
	-- Define public methods
	
	function g:jumpToImage(num)
		local i
		print("jumpToImage")
		print("#slides", #slides)
		for i = 1, #slides do
			if i < num then
				slides[i].x = -screenW*.5;
			elseif i > num then
				slides[i].x = screenW*1.5 + pad
			else
				slides[i].x = screenW*.5 - pad
			end
		end
		slideNum = num
		initSlide(slideNum)
	end

	function g:cleanUp()
		print("slides cleanUp")
		background:removeEventListener("touch", touchListener)
	end

	return g	
end

return SlideView