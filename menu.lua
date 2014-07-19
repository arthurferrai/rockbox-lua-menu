--[[
drawmodes definitions:
mode:		value:
COMPLEMENT 	0		-- invert (xor) all foreground pixels, leave background pixels as-is
BG         	1		-- leave foreground pixels as-is, draw background pixels with current background colour
FG         	2		-- draw foreground pixels with current foreground colour, leave background pixels as-is
SOLID      	3		-- draw foreground pixels with current foreground colour, draw background pixels with current background colour
INVERSEVID 	4 --used as bit modifier for basic modes
]]

local function clamp(min, max, val)
	return val < min and min or (val > max and max or val)
end

-- empty function to don't waste memory on non-functions entries
local function empty()end

local get_foreground = rb.lcd_get_foreground or empty
local set_foreground = rb.lcd_set_foreground or empty
local get_background = rb.lcd_get_background or empty
local set_background = rb.lcd_set_background or empty

Menu = {}

function Menu:new(_x,_y,_w,_h)
	local _,_,h=rb.font_getstringsize(" ", rb.FONT_UI)
	local m = {
		vp = {
			x 			= _x or 0,
			y 			= _y or 0,
			width 		= _w or rb.LCD_WIDTH - _x,
			height 		= _h or rb.LCD_HEIGHT - _y,
			font 		= rb.FONT_UI,
			fg_pattern	= get_foreground(),
			bg_pattern	= get_background(),
		},
		lineHeight = h,
		offset = 0,
		entries = {title = {},func = {}},
		selected = 1,
		visible = true,
	}
	setmetatable(m,self)
	self.__index = self
	return m
end

-- add a string entry to menu with an optional function callback (pass menu object as parameter)
function Menu:addEntry(str,callback)
	self.entries.title[#self.entries.title + 1] = str or ""
	self.entries.func[#self.entries.func + 1] = callback or empty
	return self
end

-- remove a menu entry
function Menu:removeEntry(pos)
	table.remove(self.entries.title,pos)
	table.remove(self.entries.func,pos)
	return self
end

-- relatively move selected menu item, wraps if reach end of list.
function Menu:move(qty)
	if qty ~= 0 then
		self.selected = self.selected + qty
		if self.selected > #self.entries.title then
			self.selected = self.selected - #self.entries.title
		elseif self.selected <= 0 then
			self.selected = self.selected + #self.entries.title
		end
	end
	local selectedOffset = self.selected * self.lineHeight - self.vp.height - self.offset
	selectedOffset = selectedOffset <= 0 and selectedOffset - self.lineHeight or selectedOffset
	self.offset = selectedOffset < -self.vp.height and (self.selected - 1) * self.lineHeight or 
				 (selectedOffset > 0) and self.offset + selectedOffset or self.offset
	return self
end

-- execute function associated with selected option
function Menu:choose()
	return self.entries.func[self.selected](self)
end

function Menu:draw()
	if not self.visible then return end
	-- backup original settings
	local bgOri, fgOri, dmOri = get_background(), get_foreground(), rb.lcd_get_drawmode()
	-- variables caching
	local vp = self.vp
	local offset = self.offset
	local width = vp.width
	local lineHeight = self.lineHeight
	local selected = self.selected
	-- draw menu items
	rb.set_viewport(self.vp)
	set_background(vp.bg_pattern)
	set_foreground(vp.fg_pattern)
	for k,v in ipairs(self.entries.title) do
		local _,_,h=rb.font_getstringsize(v, rb.FONT_UI)	
		local drawmode = 3 -- draw on foreground and background
		if selected ~= k then
			drawmode = bit.bxor(drawmode,4)
		end
		rb.lcd_set_drawmode(drawmode)		
		rb.lcd_fillrect(0, h*(k-1) - offset, width, lineHeight)
		drawmode = bit.bxor(drawmode,4)
		rb.lcd_set_drawmode(drawmode)
		rb.lcd_putsxy(0 , h*(k-1) - offset, v)
	end
	--restore previous settings
	set_background(bgOri)
	set_foreground(fgOri)
	rb.lcd_set_drawmode(dmOri)
	rb.set_viewport(nil)
	rb.lcd_update_rect(vp.x,vp.y,vp.width,vp.height)
end
