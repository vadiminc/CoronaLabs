MyScroller = {}
MyScroller.__index = MyScroller

function MyScroller.create(options)
   local mdl = {}
   setmetatable(mdl,MyScroller)
   --
   mdl.items = {}
   mdl.top = options.top or 0
   mdl.left = options.left or 0
   mdl.width = options.width or 0
   mdl.height = options.height or 0
   mdl.bgColor = options.bgColor or {124/255, 124/255, 255/255, 0.5}
   --
   mdl.view = display.newContainer( 0, 0 )
   --
   mdl.view.x = mdl.left
   mdl.view.y = mdl.top
   mdl.view.anchorChildren = false
   mdl.view.anchorX = 0
   mdl.view.anchorY = 0
   --
   mdl.bg = display.newRect( 0, 0, 0, 0 )
   mdl.bg.anchorX = 0
   mdl.bg.anchorY = 0
   mdl.bg:setFillColor( mdl.bgColor[1], mdl.bgColor[2], mdl.bgColor[3], mdl.bgColor[4] )
   mdl.view:insert(mdl.bg)
   --
   mdl._momentumScrolling = require( "ui.widget_momentumScrolling" )
   mdl._momentumScrolling.scrollStopThreshold = options.scrollStopThreshold or 250
   mdl._momentumScrolling.isBounceEnabled = options.isBounceEnabled or true
   mdl.scrollBarOptions = {}
   --
   mdl.scrollView = display.newGroup()
   --
   mdl.scrollView._isPlatformAndroid = "Android" == system.getInfo( "platformName" )
   mdl.scrollView._startXPos = 0
   mdl.scrollView._startYPos = 0
   mdl.scrollView._prevXPos = 0
   mdl.scrollView._prevYPos = 0
   mdl.scrollView._prevX = 0
   mdl.scrollView._prevY = 0
   mdl.scrollView._delta = 0
   mdl.scrollView._velocity = 0
   mdl.scrollView._prevTime = 0
   mdl.scrollView._lastTime = 0
   mdl.scrollView._tween = nil
   mdl.scrollView._left = options.left or 0
   mdl.scrollView._top = options.top or 0
   mdl.scrollView._width = options.width
   mdl.scrollView._height = options.height
   mdl.scrollView._topPadding = options.topPadding or 0
   mdl.scrollView._bottomPadding = options.bottomPadding or 0
   mdl.scrollView._leftPadding = options.leftPadding or 0
   mdl.scrollView._rightPadding = options.rightPadding or 0
   mdl.scrollView._moveDirection = nil
   mdl.scrollView._isHorizontalScrollingDisabled = options.isHorizontalScrollingDisabled
   mdl.scrollView._isVerticalScrollingDisabled = options.isVerticalScrollingDisabled
   mdl.scrollView._listener = options.listener
   mdl.scrollView._friction = options.friction or 0.972
   mdl.scrollView._maxVelocity = options.maxVelocity or 2
   mdl.scrollView._timeHeld = 0
   mdl.scrollView._isLocked = options.isLocked
   mdl.scrollView._scrollWidth = options.scrollWidth or options.width
   mdl.scrollView._scrollHeight = options.scrollHeight or options.height
   mdl.scrollView._trackVelocity = false   
   mdl.scrollView._updateRuntime = false

   mdl.view:insert( mdl.scrollView )
   --
   mdl.scrollView._fixedGroup = display.newGroup()
   mdl.view:insert(mdl.scrollView._fixedGroup)
   --
   mdl.scrollView.anchorX = 0
   mdl.scrollView.anchorY = 0
   mdl.scrollView.x = 0
   mdl.scrollView.y = 0
   --
   mdl:setWidth( mdl.width )
   mdl:setHeight( mdl.height )
   mdl:initListeners()
   -- INSERT EMPTY RECT INTO SCROLLVIEW
   mdl.scrollView.bg = display.newRect( 0, 0, 1, 1 )
   mdl.scrollView.bg:setFillColor( mdl.bgColor[1], mdl.bgColor[2], mdl.bgColor[3], mdl.bgColor[4] )
   mdl.scrollView.bg.anchorX = 0
   mdl.scrollView.bg.anchorY = 0
   --
   mdl.scrollView.horizontalGroup = display.newGroup()
   mdl.scrollView.verticalGroup = display.newGroup()
   mdl.scrollView.generalGroup = display.newGroup()
   --
   mdl.zIndexGeneralGroup = options.zIndexGeneralGroup or 1
   mdl.zIndexVerticalGroup = options.zIndexVerticalGroup or 2
   mdl.zIndexHorizontalGroup = options.zIndexHorizontalGroup or 3
   mdl.scrollView:insert(mdl.zIndexGeneralGroup, mdl.scrollView.generalGroup)
   mdl.scrollView:insert(mdl.zIndexHorizontalGroup, mdl.scrollView.horizontalGroup)
   mdl.scrollView:insert(mdl.zIndexVerticalGroup, mdl.scrollView.verticalGroup)
   --
   mdl.scrollView.generalGroup:insert( mdl.scrollView.bg )
   --
   mdl.tmp = nil
   return mdl
end

function MyScroller:getView()
	return self.view
end

function MyScroller:destroy()
   self:removeListeners()
   --
   if self.scrollView._scrollBar then
      display.remove( self.scrollView._scrollBar )
      self.scrollView._scrollBar = nil
   end
   --
   display.remove( self.scrollView.generalGroup )
   display.remove( self.scrollView.horizontalGroup )
   display.remove( self.scrollView.verticalGroup )
   display.remove( self.scrollView.bg )
   display.remove( self.scrollView )
   display.remove( self.bg )
   display.remove( self.view )
   self.scrollView.generalGroup = nil
   self.scrollView.horizontalGroup = nil
   self.scrollView.verticalGroup = nil
   self.scrollView.bg = nil
   self.scrollView = nil
   self.bg = nil
   self.view = nil
end

function MyScroller:setWidth( newWidth )
   self.scrollView._width = newWidth
	self.view.width = newWidth
   self.bg.width = newWidth
   self:updateScrollPositions()   
end

function MyScroller:setHeight( newHeight )
   self.scrollView._height = newHeight
	self.view.height = newHeight
   self.bg.height = newHeight
   self:updateScrollPositions()   
end

function MyScroller:updateScrollSizes()
   local maxX = 0
   local maxY = 0
   local scrollBounds = self.scrollView.contentBounds 
   for i, item in ipairs(self.items) do
      local bounds = item.contentBounds 
      if bounds.xMax > maxX then
         maxX = bounds.xMax
      end
      if bounds.yMax > maxY then
         maxY = bounds.yMax
      end
   end
   self.scrollView.bg.width = maxX - scrollBounds.xMin
   self.scrollView.bg.height = maxY - scrollBounds.yMin
   --
   self.scrollView._scrollHeight = self.scrollView.bg.height
   self.scrollView._scrollWidth = self.scrollView.bg.width
end

function MyScroller:updateScrollPositions()
   if self.scrollView._scrollBar then
      display.remove( self.scrollView._scrollBar )
      self.scrollView._scrollBar = nil
   end
   if self.scrollView._scrollHeight > self.scrollView._height or self.scrollView._scrollWidth > self.scrollView._width then --not self.scrollView._isVerticalScrollingDisabled and 
      self.scrollView._scrollBar = self._momentumScrolling.createScrollBar( self.scrollView, self.scrollBarOptions )
   end
end

function MyScroller:insert( displayObject, positionOnly )
   if displayObject.x < self.scrollView.x then displayObject.x = self.scrollView.x end
   if displayObject.y < self.scrollView.y then displayObject.y = self.scrollView.y end
   --
   self.items[#self.items+1] = displayObject
   --
   if not positionOnly then
   	self.scrollView.generalGroup:insert( displayObject )
   
   elseif "verticalOnly" == positionOnly then
      self.scrollView.verticalGroup:insert( displayObject )
   
   elseif "horizontalOnly" == positionOnly then
      self.scrollView.horizontalGroup:insert( displayObject )
   end
   --
   self:updateScrollSizes()
   --
   self:updateScrollPositions()
end

function MyScroller:remove( displayObject )
   local foundId = -1
   for i, item in ipairs(self.items) do
      if item == displayObject then
         foundId = i
         break
      end
   end
   if foundId > 0 then
      table.remove( self.items, foundId )
      self.scrollView:remove( displayObject )

   end
   self:updateScrollSizes()
end

function MyScroller:takeFocus( event )
   local target = event.target
   
   -- Remove focus from the object
   display.getCurrentStage():setFocus( target, nil )
   
   -- Handle turning widget buttons back to their default state (visually, ie their default button images & labels)
   if "table" == type( target ) then
      if "string" == type( target._widgetType ) then
         -- Remove focus from the widget
         target:_loseFocus()
      end
   end
   
   -- Create our new event table
   local newEvent = {}
   
   -- Copy the event table's keys/values into our newEvent table
   for k, v in pairs( event ) do
      newEvent[k] = v
   end

   -- Set our new event's phase to began, and it's target to the view
   newEvent.phase = "began"
   newEvent.target = self.scrollView
   
   -- Send a touch event to the view
   self.scrollView:touch( newEvent )
end

function MyScroller:initListeners()
   self.scrollView.parentLink = self
   function self.scrollView:touch( event )
      local phase = event.phase 
      local time = event.time
      
      -- Set the time held
      if "began" == phase then
         self._timeHeld = event.time
      end   
      -- Android fix for objects inserted into scrollView's
      if self._isPlatformAndroid then
         -- Distance moved
           local dy = mAbs( event.y - event.yStart )
         local dx = mAbs( event.x - event.xStart )
         local moveThresh = 20

         -- If the finger has moved less than the desired range, set the phase back to began (Android only fix, iOS doesn't exhibit this touch behavior..)
         if dy < moveThresh then
            if dx < moveThresh then
               if phase ~= "ended" and phase ~= "cancelled" then
                  event.phase = "began"
               end
            end
         end
      end
                  
      -- Handle momentum scrolling (and the view isn't locked)
      if not self._isLocked and self._scrollBar then
         self.parentLink._momentumScrolling._touch( self, event )
      end
      
      -- Execute the listener if one is specified
      if self._listener then
         local newEvent = {}
         
         for k, v in pairs( event ) do
            newEvent[k] = v
         end
         
         -- Set event.target to the scrollView object, not the view
         newEvent.target = self.parent
         
         -- Execute the listener
         self._listener( newEvent )
      end
            
      -- Set the view's phase so we can access it in the enterFrame listener below
      self._phase = event.phase
      
      -- Set the view's target object (the object we touched) so we can access it in the enterFrame listener below
      self._target = event.target

      --[[
      if event.phase == "began" then
         self.defMoveX = self.x
         self.defMoveY = self.y
         self.isFocus = true
         print ("scroll began")
         display.getCurrentStage():setFocus( self )
      elseif event.phase == "moved" then
         print ("scroll move")
         if not self.defMoveX then
            print ("^^^^^^^1")
            self.defMoveX = self.x
         end
         if not self.defMoveY then
            print ("^^^^^^^2")
            self.defMoveY = self.y
         end

         local viewBounds = self.parentLink.view.contentBounds 
         local scrollBounds = self.contentBounds
         --
         -- X Scroll
         --
         local toX = self.defMoveX + (event.x - event.xStart)
         if scrollBounds.xMin <= viewBounds.xMin+1 and (toX + self.width) >= (viewBounds.xMax - viewBounds.xMin) then
            if toX > 0 then 
               toX = 0
            end
            --transition.cancel()
            transition.to( self, { time=500, x=toX, transition=easing.outSine } )
         end
         --
         -- Y Scroll
         --
         local toY = self.defMoveY + (event.y - event.yStart)
         if scrollBounds.yMin <= viewBounds.yMin+1 and (toY + self.height) >= (viewBounds.yMax - viewBounds.yMin) then
            if toY > 0 then 
               toY = 0
            end
            --transition.cancel()
            transition.to( self, { time=500, y=toY, transition=easing.outSine } )
         end
         --
         --
         --
      elseif event.phase == "ended" or event.phase == "cancelled" then
         print("scroll ended")
         self.defMoveX = nil
         self.defMoveY = nil
         self.isFocus = false
         display.getCurrentStage():setFocus( nil )
      end
      ]]
      return true
   end
   self.scrollView:addEventListener( "touch", self.scrollView )

   self.onEnterFrameListener = function( event )
      -- Handle momentum @ runtime
      if self.scrollView._scrollBar then
         self._momentumScrolling._runtime( self.scrollView, event )
      end
      
      -- Update the top position of the scrollView (if moved)
      if self.scrollView.y ~= self.scrollView._top then
         self.scrollView._top = self.scrollView.y
      end

      return true
      --self:onEnterFrameChecker( event )
   end
   Runtime:addEventListener( "enterFrame", self.onEnterFrameListener )
end

--[[
function MyScroller:onEnterFrameChecker( event )
   local viewBounds = self.view.contentBounds 
   local scrollBounds = self.scrollView.contentBounds
   if self.scrollView.width > self.view.width then
      if scrollBounds.xMin > viewBounds.xMin then 
         self.scrollView.x = self.scrollView.x - (scrollBounds.xMin - viewBounds.xMin)
      end
      if scrollBounds.xMax < viewBounds.xMax then 
         self.scrollView.x = self.scrollView.x + (viewBounds.xMax - scrollBounds.xMax)
      end
   end
   if self.scrollView.height > self.view.height then
      if scrollBounds.yMin > viewBounds.yMin then 
         self.scrollView.y = self.scrollView.y - (scrollBounds.yMin - viewBounds.yMin)
      end
      if scrollBounds.yMax < viewBounds.yMax then 
         self.scrollView.y = self.scrollView.y + (viewBounds.yMax - scrollBounds.yMax)
      end
   end
end

]]
function MyScroller:removeListeners()
   self.scrollView:removeEventListener( "touch", self.scrollView )
   Runtime:removeEventListener( "enterFrame", self.onEnterFrameListener )
end