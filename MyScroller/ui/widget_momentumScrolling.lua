-- Copyright © 2013 Corona Labs Inc. All Rights Reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of the company nor the names of its contributors
--      may be used to endorse or promote products derived from this software
--      without specific prior written permission.
--    * Redistributions in any form whatsoever must retain the following
--      acknowledgment visually in the program (e.g. the credits of the program): 
--      'This product includes software developed by Corona Labs Inc. (http://www.coronalabs.com).'
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL CORONA LABS INC. BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


local M = 
{
	_directoryPath = "ui.",
}

-- Localize math functions
local mAbs = math.abs
local mFloor = math.floor

-- configuration variables
M.scrollStopThreshold = 250

-- Function to set the view's limits
local function setLimits( self, view )
	-- Set the bottom limit
	self.bottomLimit = view._topPadding
	
	-- Set the upper limit
	if view._scrollHeight then
		self.upperLimit = ( -view._scrollHeight + view._height ) - view._bottomPadding
	end
	
	-- Set the right limit
	self.rightLimit = view._leftPadding

	-- Set the left limit
	if view._scrollWidth then
		self.leftLimit = ( - view._scrollWidth + view._width ) - view._rightPadding
	end
end

-- Function to handle vertical "snap back" on the view
local function handleSnapBackVertical( self, view, snapBack )
	
	-- Set the limits now
	setLimits( M, view )
	
	local limitHit = "none"
	local bounceTime = 400
	if not self.isBounceEnabled then
	    bounceTime = 0
	end
	
	-- Snap back vertically
	if not view._isVerticalScrollingDisabled and view._scrollHeight > view._height then
		-- Put the view back to the top if it isn't already there ( and should be )
		if view.generalGroup.y > self.bottomLimit then
			-- Set the hit limit
			limitHit = "bottom"
			
			-- Transition the view back to it's maximum position
			if "boolean" == type( snapBack ) then
				if snapBack == true then
					-- Ensure the scrollBar is at the bottom of the view
					if view._scrollBar then
						view._scrollBar:setPositionTo( "top" )
					end
					
					-- Put the view back to the top
					view._tween = transition.to( view.generalGroup, { time = bounceTime, y = self.bottomLimit, transition = easing.outQuad } )						
					view._tween = transition.to( view.verticalGroup, { time = bounceTime, y = self.bottomLimit, transition = easing.outQuad } )						
				end
			end
			
		-- Put the view back to the bottom if it isn't already there ( and should be )
		elseif view.generalGroup.y < self.upperLimit then		
			-- Set the hit limit
			limitHit = "top"
			
			-- Transition the view back to it's maximum position
			if "boolean" == type( snapBack ) then
				if snapBack == true then
					-- Ensure the scrollBar is at the bottom of the view
					if view._scrollBar then
						view._scrollBar:setPositionTo( "bottom" )			
					end
					
					-- Put the view back to the bottom
					view._tween = transition.to( view.generalGroup, { time = bounceTime, y = self.upperLimit, transition = easing.outQuad } )
					view._tween = transition.to( view.verticalGroup, { time = bounceTime, y = self.upperLimit, transition = easing.outQuad } )
				end
			end
		end
	end
	
	return limitHit
end
	
-- Function to handle horizontal "snap back" on the view
local function handleSnapBackHorizontal( self, view )

	-- Set the limits now
	setLimits( M, view )

	local limitHit = "none"
	local bounceTime = 400
	if not self.isBounceEnabled then
	    bounceTime = 0
	end
	
	-- Snap back horizontally
	if not view._isHorizontalScrollingDisabled  and view._scrollWidth > view._width then
		-- Put the view back to the left if it isn't already there ( and should be )
		if view.generalGroup.x < self.leftLimit then
			-- Set the hit limit
			limitHit = "left"
			
			-- Transition the view back to it's maximum position
			view._tween = transition.to( view.generalGroup, { time = bounceTime, x = self.leftLimit, transition = easing.outQuad } )
			view._tween = transition.to( view.horizontalGroup, { time = bounceTime, x = self.leftLimit, transition = easing.outQuad } )
		-- Put the view back to the right if it isn't already there ( and should be )
		elseif view.generalGroup.x > self.rightLimit then
			-- Set the hit limit
			limitHit = "right"
			
			-- Transition the view back to it's maximum position
			view._tween = transition.to( view.generalGroup, { time = bounceTime, x = self.rightLimit, transition = easing.outQuad } )
			view._tween = transition.to( view.horizontalGroup, { time = bounceTime, x = self.rightLimit, transition = easing.outQuad } )
		end
	end
	
	return limitHit
end

-- Function to clamp velocity to the maximum value
local function clampVelocity( view )
	-- Throttle the velocity if it goes over the max range
	if view._velocity < -view._maxVelocity then
		view._velocity = -view._maxVelocity
	elseif view._velocity > view._maxVelocity then
		view._velocity = view._maxVelocity
	end
end


-- Handle momentum scrolling touch
function M._touch( view, event )
	local phase = event.phase
	local time = event.time
	if "began" == phase then	
		-- Reset values	
		view._startXPos = event.x
		view._startYPos = event.y
		view._prevXPos = event.x
		view._prevYPos = event.y
		view._prevX = 0
		view._prevY = 0
		view._delta = 0
		view._velocity = 0
		view._prevTime = 0
		view._moveDirection = nil
		view._trackVelocity = true
		view._updateRuntime = false
		
		-- Set the limits now
		setLimits( M, view )
		
		-- Cancel any active tween on the view
		if view._tween then
			transition.cancel(view._tween)
			view._tween = nil
		end				
		
		-- Set focus
		display.getCurrentStage():setFocus( event.target, event.id )
		view._isFocus = true
	
	elseif view._isFocus then
		if "moved" == phase then
			-- Set the move direction		
			if not view._moveDirection then
		        local dx = mAbs( event.x - event.xStart )
	            local dy = mAbs( event.y - event.yStart )
	            local moveThresh = 12
				
	            if dx > moveThresh or dy > moveThresh then
					-- If there is a scrollBar, show it
					if view._scrollBar then
						-- Show the scrollBar
						view._scrollBar:show()
					end
		
	                if dx > dy then
						-- If horizontal scrolling is enabled
						if not view._isHorizontalScrollingDisabled and view._scrollWidth > view._width then
							-- The move was horizontal
	                    	view._moveDirection = "horizontal"
						
							-- Handle vertical snap back
							handleSnapBackVertical( M, view, true )						
						end
	                else
						-- If vertical scrolling is enabled
						if not view._isVerticalScrollingDisabled  and view._scrollHeight > view._height then
							-- The move was vertical
		                    view._moveDirection = "vertical"
							-- Handle horizontal snap back
							handleSnapBackHorizontal( M, view, true )						
	                	end
					end
				end
			end
			
			-- Horizontal movement
			if "horizontal" == view._moveDirection then
				-- If horizontal scrolling is enabled
				if not view._isHorizontalScrollingDisabled  and view._scrollWidth > view._width then					
					view._delta = event.x - view._prevXPos
					view._prevXPos = event.x
				
					-- If the view is more than the limits
					if view.generalGroup.x < M.leftLimit or view.generalGroup.x > M.rightLimit then
						view.generalGroup.x = view.generalGroup.x + ( view._delta * 0.5 )
					else
						view.generalGroup.x = view.generalGroup.x + view._delta
					end
					view.horizontalGroup.x = view.generalGroup.x
					
					local limit = handleSnapBackHorizontal( M, view, true )
					
				end
				
			-- Vertical movement
			else
				-- If vertical scrolling is enabled
				if not view._isVerticalScrollingDisabled  and view._scrollHeight > view._height then
					view._delta = event.y - view._prevYPos
					view._prevYPos = event.y
					
					-- If the view is more than the limits
					if view.generalGroup.y < M.upperLimit or view.generalGroup.y > M.bottomLimit then
						view.generalGroup.y = view.generalGroup.y + ( view._delta * 0.5 )
					else
						view.generalGroup.y = view.generalGroup.y + view._delta 
					end
					view.verticalGroup.y = view.generalGroup.y
					
					-- Handle limits
					-- if bounce is true, then the snapback parameter has to be true, otherwise false
					local limit
					
					if M.isBounceEnabled == true then 
					    -- if bounce is enabled and the view is used in picker, we snap back to prevent infinite scrolling
					    if view._isUsedInPickerWheel == true then
					        limit = handleSnapBackVertical( M, view, true )
					    else
					    -- if not used in picker, we don't need snap back so we don't lose elastic behaviour on the tableview
					        limit = handleSnapBackVertical( M, view, false )
					    end
					else
					    limit = handleSnapBackVertical( M, view, true )
					end
					
					-- Move the scrollBar
					if limit ~= "top" and limit ~= "bottom" then
						if view._scrollBar then						
							view._scrollBar:move()
						end
					end
					
					-- Set the time held
					--view._timeHeld = time				
				end
			end
			
		elseif "ended" == phase or "cancelled" == phase then
		
			-- Reset values				
			view._lastTime = event.time
			view._trackVelocity = false			
			view._updateRuntime = true
			if event.time - view._timeHeld > M.scrollStopThreshold then
			    view._velocity = 0
			end
			view._timeHeld = 0
			
			-- when tapping fast and the view is at the limit, the velocity changes sign. This ALWAYS has to be treated.
			if view._delta > 0 and view._velocity < 0 then
			    view._velocity = - view._velocity
			end
			
			if view._delta < 0 and view._velocity > 0 then
			    view._velocity = - view._velocity
			end
	
			-- Remove focus								
			display.getCurrentStage():setFocus( nil )
			view._isFocus = nil
		end
	end
end


-- Handle runtime momentum scrolling events.
function M._runtime( view, event )
	-- If we are tracking runtime
	if view._updateRuntime then		
		local timePassed = event.time - view._lastTime
		view._lastTime = view._lastTime + timePassed
		
		-- Stop scrolling if velocity is near zero
		if mAbs( view._velocity ) < 0.01 then
			view._velocity = 0
			view._updateRuntime = false
			
			-- Hide the scrollBar
			if view._scrollBar then
				view._scrollBar:hide()
			end
		end
		
		-- Set the velocity
		view._velocity = view._velocity * view._friction
		
		-- Clamp the velocity if it goes over the max range
		clampVelocity( view )
	
		-- Horizontal movement
		if "horizontal" == view._moveDirection then
			-- If horizontal scrolling is enabled
			if not view._isHorizontalScrollingDisabled  and view._scrollWidth > view._width then
				-- Reset limit values
				view._hasHitLeftLimit = false
				view._hasHitRightLimit = false
				
				-- Move the view
				view.generalGroup.x = view.generalGroup.x + view._velocity * timePassed
				view.horizontalGroup.x = view.generalGroup.x
			
				-- Handle limits
				local limit = handleSnapBackHorizontal( M, view )
			
				-- Left
				if "left" == limit then					
					-- Stop updating the runtime now
					view._updateRuntime = false
					
					-- If there is a listener specified, dispatch the event
					if view._listener then
						-- We have hit the left limit
						view._hasHitLeftLimit = true
						
						local newEvent = 
						{
							direction = "left",
							limitReached = true,
							target = view,
						}
						
						view._listener( newEvent )
					end
			
				-- Right
				elseif "right" == limit then					
					-- Stop updating the runtime now
					view._updateRuntime = false
					
					-- If there is a listener specified, dispatch the event
					if view._listener then
						-- We have hit the right limit
						view._hasHitRightLimit = true
						
						local newEvent = 
						{
							direction = "right",
							limitReached = true,
							target = view,
						}
						
						view._listener( newEvent )
					end
				end
			end	
			
		-- Vertical movement		
		else
			-- If vertical scrolling is enabled
			if not view._isVerticalScrollingDisabled  and view._scrollHeight > view._height then
				-- Reset limit values
				view._hasHitBottomLimit = false
				view._hasHitTopLimit = false
				
				-- Move the view
				view.generalGroup.y = view.generalGroup.y + view._velocity * timePassed
				view.verticalGroup.y = view.generalGroup.y
				
				-- Move the scrollBar
				if view._scrollBar then						
					view._scrollBar:move()
				end
	
				-- Handle limits
				-- if we have motion, then we check for snapback. otherwise, we don't.
				local limit
				
				if "vertical" == view._moveDirection then
                    limit = handleSnapBackVertical( M, view, true )
                else
                    limit = handleSnapBackVertical( M, view, false )
                end
	
				-- Top
				if "top" == limit then					
					-- Hide the scrollBar
					if view._scrollBar then
						view._scrollBar:hide()
					end
					
					-- We have hit the top limit
					view._hasHitTopLimit = true
										
					-- Stop updating the runtime now
					view._updateRuntime = false
										
					-- If there is a listener specified, dispatch the event
					if view._listener then
						local newEvent = 
						{
							direction = "up",
							limitReached = true,
							phase = event.phase,
							target = view,
						}
						
						view._listener( newEvent )
					end
							
				-- Bottom
				elseif "bottom" == limit then				
					-- Hide the scrollBar
					if view._scrollBar then
						view._scrollBar:hide()
					end
										
					-- We have hit the bottom limit
					view._hasHitBottomLimit = true
					
					-- Stop updating the runtime now
					view._updateRuntime = false
					
					-- If there is a listener specified, dispatch the event
					if view._listener then
						local newEvent = 
						{
							direction = "down",
							limitReached = true,
							target = view,
						}
						
						view._listener( newEvent )
					end
				end
			end
		end
	end
	
	-- If we are tracking velocity
	if view._trackVelocity then	
		-- Calculate the time passed
		local newTimePassed = event.time - view._prevTime
		view._prevTime = view._prevTime + newTimePassed

		-- Horizontal movement
		if "horizontal" == view._moveDirection then
			-- If horizontal scrolling is enabled
			if not view._isHorizontalScrollingDisabled  and view._scrollWidth > view._width then
				if view._prevX then
					local possibleVelocity = ( view.generalGroup.x - view._prevX ) / newTimePassed

	                if possibleVelocity ~= 0 then
	                    view._velocity = possibleVelocity
	
						-- Clamp the velocity if it goes over the max range
						clampVelocity( view )
	                end
				end
		
				view._prevX = view.generalGroup.x
			end
		
		-- Vertical movement
		elseif "vertical" == view._moveDirection then
			-- If vertical scrolling is enabled
			if not view._isVerticalScrollingDisabled then
				if view._prevY then
					local possibleVelocity = ( view.generalGroup.y - view._prevY ) / newTimePassed
                    
					if possibleVelocity ~= 0 then
                        view._velocity = possibleVelocity
						-- Clamp the velocity if it goes over the max range
						clampVelocity( view )
                    end
				end
		
				view._prevY = view.generalGroup.y
			end
		end
	end
end


-- Function to create a scrollBar
function M.createScrollBar( view, options )
	-- Require needed widget files
	local _widget = nil

	-- Function to require the widget file from the widget directory path (if it exists)
	local function checkFileAtPath()
	    _widget = require( M._directoryPath .. "widget" )
	end

	-- If we failed to find the widget file in the widget directory path.
	if false == pcall( checkFileAtPath ) then
		_widget = require( "widget" )
	end
	
	local opt = {}
	local customOptions = options or {}
	
	-- Setup the scrollBar's width/height
	local parentGroup = view.parent --.parent
	local scrollBarWidth = options.width or 5
	local viewHeight = view._height -- The height of the windows visible area
	local viewContentHeight = view._scrollHeight -- The height of the total content height
	local minimumScrollBarHeight = 24 -- The minimum height the scrollbar can be

	-- Set the scrollbar Height
	local scrollBarHeight = ( viewHeight * 100 ) / viewContentHeight
	
	-- If the calculated scrollBar height is below the minimum height, set it to it
	if scrollBarHeight < minimumScrollBarHeight then
		scrollBarHeight = minimumScrollBarHeight
	end
	
	-- Grab the theme options for the scrollBar
	local themeOptions = _widget.theme.scrollBar
	
	-- Get the theme sheet file and data
	opt.sheet = options.sheet
	opt.themeSheetFile = themeOptions.sheet
	opt.themeData = themeOptions.data
	opt.width = options.frameWidth or options.width or themeOptions.width
	opt.height = options.frameHeight or options.height or themeOptions.height
	
	-- Grab the frames
	opt.topFrame = options.topFrame or _widget._getFrameIndex( themeOptions, themeOptions.topFrame )
	opt.middleFrame = options.middleFrame or _widget._getFrameIndex( themeOptions, themeOptions.middleFrame )
	opt.bottomFrame = options.bottomFrame or _widget._getFrameIndex( themeOptions, themeOptions.bottomFrame )
	
	-- Create the scrollBar imageSheet
	local imageSheet
	
	if opt.sheet then
		imageSheet = opt.sheet
	else
		local themeData = require( opt.themeData )
	 	imageSheet = graphics.newImageSheet( opt.themeSheetFile, themeData:getSheet() )
	end
	
	-- The scrollBar is a display group
	M.scrollBar = display.newGroup()
	
	-- Create the scrollBar frames ( 3 slice )
	M.topFrame = display.newImageRect( M.scrollBar, imageSheet, opt.topFrame, opt.width, opt.height )
	M.middleFrame = display.newImageRect( M.scrollBar, imageSheet, opt.middleFrame, opt.width, opt.height )
	M.bottomFrame = display.newImageRect( M.scrollBar, imageSheet, opt.bottomFrame, opt.width, opt.height )
	
	-- Set the middle frame's width
	M.middleFrame.height = scrollBarHeight - ( M.topFrame.contentHeight + M.bottomFrame.contentHeight )
	
	-- Positioning
	M.middleFrame.y = M.topFrame.y + M.topFrame.contentHeight * 0.5 + M.middleFrame.contentHeight * 0.5
	M.bottomFrame.y = M.middleFrame.y + M.middleFrame.contentHeight * 0.5 + M.bottomFrame.contentHeight * 0.5
	
	-- Setup the scrollBar's properties
	M.scrollBar._viewHeight = viewHeight
	M.scrollBar._viewContentHeight = viewContentHeight
	M.scrollBar.alpha = 0 -- The scrollBar is invisible initally
	M.scrollBar._tween = nil
	
	-- function to recalculate the scrollbar params, based on content height change
	function M.scrollBar:repositionY()
	
	    self._viewHeight = view._height
	    self._viewContentHeight = view._scrollHeight
	    -- Set the scrollbar Height
	    
	    local scrollBarHeight = ( viewHeight * 100 ) / viewContentHeight
	    
	    -- If the calculated scrollBar height is below the minimum height, set it to it
	    if scrollBarHeight < minimumScrollBarHeight then
		    scrollBarHeight = minimumScrollBarHeight
	    end
	
        M.middleFrame.height = scrollBarHeight - ( M.topFrame.contentHeight + M.bottomFrame.contentHeight ) 
    
	end
	
	-- Function to move the scrollBar
	function M.scrollBar:move()
		local moveFactor = ( view.generalGroup.y * 100 ) / ( self._viewContentHeight - self._viewHeight )		
		local moveQuantity = ( moveFactor * ( self._viewHeight - self.contentHeight ) ) / 100
				
		if view.generalGroup.y < 0 then
			-- Only move if not over the bottom limit
			if mAbs( view.generalGroup.y ) < ( self._viewContentHeight - self._viewHeight ) then
				self.y = view.parent.y - view._top - moveQuantity
			end
		end		
	end
	
	function M.scrollBar:setPositionTo( position )
		if "top" == position then
			self.y = view.parent.y - view._top
		elseif "bottom" == position then
			self.y = self._viewHeight - self.contentHeight
		end
	end
	
	-- Function to show the scrollBar
	function M.scrollBar:show()
		-- Cancel any previous transition
		if self._tween then
			transition.cancel() 
			self._tween = nil
		end
		
		-- Set the alpha of the bar back to 1
		self.alpha = 1
	end
	
	-- Function to hide the scrollBar
	function M.scrollBar:hide()
		-- If there already isn't a tween in progress
		if not self._tween then
			self._tween = transition.to( self, { time = 400, alpha = 0, transition = easing.outQuad } )
		end
	end
		
	-- Insert the scrollBar into the fixed group and position it
	view._fixedGroup:insert( M.scrollBar )
	view._fixedGroup.anchorX = 0
	view._fixedGroup.anchorY = 0
	view._fixedGroup.x = view._width - 20 - scrollBarWidth * 0.5
	view._fixedGroup.y = view._top + ( M.scrollBar.contentHeight * 0.5 )

	return M.scrollBar
end

return M
