require "menu"
require "buttons"
-- switch behavior function
-- value: value to be searched in list
-- list: possibilities in format: [value] = function() <actions> end
-- if [value] is nil, try with ["default"]
-- returns the entry return value

local function switch(value,list)
	if list[value] then 
		return list[value]()
	elseif list["default"] then
		return list["default"]()
	end
	return nil
end

local MENU_SELECT = rb.buttons.BUTTON_SELECT
local MENU_NEXT = rb.buttons.BUTTON_SCROLL_FWD
local MENU_NEXT_REPEAT = bit.bor(rb.buttons.BUTTON_SCROLL_FWD,rb.buttons.BUTTON_REPEAT)
local MENU_PREV = rb.buttons.BUTTON_SCROLL_BACK
local MENU_PREV_REPEAT = bit.bor(rb.buttons.BUTTON_SCROLL_BACK,rb.buttons.BUTTON_REPEAT)


local CYCLETIME = rb.HZ / 50
local done = false
local activeMenu
local menu2, mainMenu

mainMenu = Menu:new(10,10,30,50)
				 :addEntry("01")
				 :addEntry("02")
				 :addEntry("03")
				 :addEntry("04")
				 :addEntry("05")
				 :addEntry("06")
				 :addEntry("07")
				 :addEntry("next menu", function(m)	activeMenu = menu2 end)
				 :addEntry("exit",function() done = true end)

menu2 = Menu:new(50,10,30,50)
			  :addEntry("one")
			  :addEntry("two")
			  :addEntry("back", function(m)	activeMenu = mainMenu end)
activeMenu = mainMenu
function test()
	while not done do
		-- frame rate control
		local endtick = rb.current_tick() + CYCLETIME
		--
		rb.lcd_clear_display()
		local but = rb.button_get(false)
		switch(but, {
			[MENU_SELECT] = function() activeMenu:choose() end,
			[MENU_NEXT] = function() activeMenu:move(1) end,
			[MENU_NEXT_REPEAT] = function() activeMenu:move(1) end,
			[MENU_PREV] = function() activeMenu:move(-1) end,
			[MENU_PREV_REPEAT] = function() activeMenu:move(-1) end,
		})
		activeMenu:draw()
		
		rb.lcd_update()
		
		while rb.current_tick() < endtick do
			rb.yield()
		end
	end
end

test()
