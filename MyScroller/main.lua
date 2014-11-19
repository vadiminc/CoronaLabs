display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background",  255/255, 255/255, 255/255 )

require ("ui.MyScroller")

local scrollView_parent = MyScroller.create({
	top = 100,
	left = 100,
	width = 200,
	height = 200,
})

local myText1 = display.newText( "1>Hello, World\n2>Hello World\n3>Hello World!4>Hello, World\n5>Hello World\n6>Hello World!7>Hello, World\n8>Hello World\n9>Hello World!10>Hello, World\n11>Hello World\n12>Hello World!", 0, 0, native.systemFont, 40 )
myText1.anchorX = 0
myText1.anchorY = 0
myText1.x = 0
myText1:setFillColor( 1, 0, 0 )

local myText2 = display.newText( "Continue, Thinking*", 0, 0, native.systemFont, 30 )
myText2.anchorX = 0
myText2.anchorY = 0
myText2.x = 10
myText2.y = 10
myText2:setFillColor( 0, 1, 0 )

local myText3 = display.newText( "I'm HERE MAN HELLOOOOOOOOOOO*", 0, 0, native.systemFont, 30 )
myText3.anchorX = 0
myText3.anchorY = 0
myText3.x = 10
myText3.y = 60
myText3:setFillColor( 0, 0, 1 )


scrollView_parent:insert( myText1 ) -- insert and center text
scrollView_parent:insert( myText2, "verticalOnly" ) -- insert and center text
scrollView_parent:insert( myText3, "horizontalOnly" ) -- insert and center text

scrollView_parent:setHeight(300)
scrollView_parent:setWidth(400)

--scrollView_parent:destroy()