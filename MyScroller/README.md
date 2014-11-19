MyScroller (extended by ScrollView) v 1.0

Demo code:

```XHTML
local scrollView_parent = MyScroller.create({
	top = 100,
	left = 100,
	width = 200,
	height = 200,
})

...

-- You can set how the object should be scrolled in the scroll panel.
scrollView_parent:insert( myText1 )
scrollView_parent:insert( myText2, "verticalOnly" )
scrollView_parent:insert( myText3, "horizontalOnly" )

-- You can change height and width in a fly without any troubles
scrollView_parent:setHeight(300)
scrollView_parent:setWidth(400)


--scrollView_parent:destroy()
```