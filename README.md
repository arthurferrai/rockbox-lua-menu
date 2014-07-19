#rockbox-lua-menu

A (very) simple menu implementation for Rockbox Lua interpreter. It will draw a menu similar to the Rockbox's menus. Doesn't support (yet) icons and scroll bar. Untested on touch devices.

# How to use

First, require the `menu.lua` file on your code, and you're ready to go:

    require "menu"
    require "buttons"
    local exiting = false
    local CYCLETIME = rb.HZ / 50

    local mainMenu = Menu:new(10,10,30,50)
                     :addItem("first item") -- supports method chaining
                     :addItem("second item")
                     :addItem("third item")
                     :addItem("exit", function () exiting = true end) -- supports callback

    while not exiting do
        rb.lcd_clear_display()
        local endtick = rb.current_tick() + CYCLETIME
        local but = rb.button_get(false)
        if but == rb.buttons.BUTTON_SELECT then
            activeMenu:choose()
        elseif but == rb.buttons.BUTTON_SCROLL_FWD then
            activeMenu:move(1)
        elseif but == rb.buttons.BUTTON_SCROLL_BACK then
            activeMenu:move(-1)
        end
        mainMenu:draw()
        rb.lcd_update()
        while rb.current_tick() < endtick do
            rb.yield()
        end
    end

Or take a look at `test.lua`.

# Documentation

Except for Menu:choose and Menu:draw, every method is chainable.

## Menu:new(x,y,w,h)

Creates a new menu object.

### Parameters

* *x*: the top-left x menu position
* *y*: the top-left y menu position
* *w*: the menu total width
* *h*: the menu total height

## Menu:addEntry(str[, callback])

Add a menu entry with an optional callback. The callback will be called when you call Menu:choose().

### Parameters

* *str*: The menu entry text that will be shown on menu
* *callback*: The callback that will be called when the option is selected using Menu:choose

## Menu:removeEntry(pos)

Removes a menu entry

### Parameters

* *pos*: position of the entry that will be removed

## Menu:move(qty)

Changes the selected entry of menu

### Parameters

* *qty*: delta of the selection movement (a value of 2 will advance the selected option twice downwards)

## Menu:choose()

Call the callback associated with the selected option, if any.

## Menu:draw()

Draws the menu on screen.