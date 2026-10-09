local lg = love.graphics

local proj_name = "plot"
local imgdir
local fhand

local image

local imageshown = true

local drawline = true

local scale = 2

local px, py = {}, {}
local mx, my = 0, 0

local pt = {}

local ptstyle = 1

local issaved = true

local index = 1

function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function love.load()
	lg.setDefaultFilter("nearest", "nearest", 0)
	image = lg.newImage("nofile.png")
	
	pt = {
		[1] = lg.newImage("pointimg/1.png"),
		[2] = lg.newImage("pointimg/2.png"),
		[3] = lg.newImage("pointimg/3.png"),
		[4] = lg.newImage("pointimg/4.png"),
	}
	
	love.window.setMode(265 * scale, 165 * scale)	
end

function love.update()
	love.mouse.setVisible(false)
	mx, my = love.mouse.getPosition()
	mx, my = math.floor(mx/scale+.5), math.floor(my/scale+.5)
	--love.window.setTitle(proj_name .. (typing and "?" or "") .. " | " .. scale .. "x | " .. #px .. "pts")
end

function love.filedropped(file)
	local filename = file:getFilename()
	local ext = filename:match("%.%w+$")

	if ext == ".png" then
		file:open("r")
		fileData = file:read("data")
		image = love.image.newImageData(fileData)
		image = love.graphics.newImage(image)
		imgdir = filename
		imageshown = true
	end
	
	if ext == ".csv" then
		file:open("r")
		fileData = file:read()
		local a = split(fileData, "\n")
		px = split(a[1], ",")
		py = split(a[2], ",")
		issaved = true
	end
end

function love.keypressed(key)
	if key == "f1" then
		love.window.showMessageBox("About ttmps",
[[Thing That Makes Plot Sprites (ttmps)
Version 1.0
Created by Mostafa T. Mortada
Using LÖVE framework

How to use:
--------------------------
To load an image to trace over, drag a .PNG file over the window.
To import a list of points, do the same but with a .CSV file,
where the first row is the X position of the points and the second
row is the Y position of the points.

A: add point at cursor location
D: remove selected point
P: remove all points

Q: select first point
W: select closest point to cursor
E: select last point
-: select previous point
=: select next point

T: export points to a .CSV file with the same name and
in the same directory as the reference PNG image.

Z/X/C/V: change point style
M: toggle image visibility
N: toggle line visibility

1-9: change window scale
F1: opens this window
F2: shows information for current instance of ttmps]],
"info", false)
	end
	
	if key == "f2" then
		love.window.showMessageBox("Session information",
		"Image location: "..(imgdir or "None loaded") .. "\n" ..
		"There are " .. #px .. " points.",
		"info", false)
	end

	if key == "t" and imgdir then
		local h = io.open(imgdir:sub(1, imgdir:len()-4) .. ".csv", "w")
		h:write(table.concat(px, ",").."\n")
		h:write(table.concat(py, ",").."\n")
		h:close()
		issaved = true
	end
	if key == "m" then
		imageshown = not imageshown
	end
	if key == "n" then
		drawline = not drawline
	end
	if key == "p" then px, py = {}, {} issaved = false end
	if key == "a" then
		table.insert(px, index, mx)
		table.insert(py, index, my)
		--px[#px+1] = mx
		--py[#py+1] = my
		if index ~= 1 or #px == 1 then
			index = index + 1
		end
		issaved = false
	end
	if key == "d" then
		table.remove(px, math.min(index, #px))
		table.remove(py, math.min(index, #py))
		issaved = false
	end
	
	index = key=="q" and 1 or key=="e" and #px+1 or index
	index = math.max(1, math.min(#px + 1, index + (key=="-" and -1 or key=="=" and 1 or 0)))
	if key == "w" then
		local d = 10000000
		for i = 1, #px do
			local pd = (px[i]-mx)^2 + (py[i]-my)^2
			if  pd < d then
				d = pd
				index = i
			end
		end
		
	end
	
	if tonumber(key) and key ~= "0" then
		scale = tonumber(key)
		love.window.setMode(265 * scale, 165 * scale)
	end
	
	ptstyle = key=="z" and 1 or key=="x" and 2 or key=="c" and 3 or key=="v" and 4 or ptstyle
end

function love.draw()
	lg.push()
	lg.scale(scale, scale)
	lg.clear(1, 1, 1)
	lg.setColor(.9, .9, .9)
	for x = 0, 264/7 do
		for y = 0, 164/7 do
			if (x+y)%2 == 0 then
				lg.rectangle("fill", x*7, y*7, 7, 7)
			end
		end
	end
	lg.setColor(1, 0, 0)
	lg.setColor(1, 1, 1)
	if imageshown then
		if image:getWidth() / image:getHeight() < 264/164 then
			lg.draw(image, 0, 0, 0, 165/image:getHeight())
		else
			lg.draw(image, 0, 0, 0, 265/image:getWidth())
		end
	end
	lg.setColor(0, 0, 1)
	--lg.print(proj_name, 0, 0)
	lg.setColor(0, 0, 0)
	lg.setLineWidth(2)
	lg.setLineStyle("rough")
	if #px == 1 then
		lg.draw(pt[ptstyle], px[1] - 3, py[1] - 3)
	end
	for i = 1, #px-1 do
		lg.setColor(0, 0, 0)
		if drawline then
			lg.line(px[i]+.5, py[i]+.5, px[i+1]+.5, py[i+1]+.5)
		end
		lg.draw(pt[ptstyle], px[i] - 3, py[i] - 3)
		lg.draw(pt[ptstyle], px[i+1] - 3, py[i+1] - 3)
	end
	lg.setColor(0, 0, 1, .5)
	if #px > 0 then
		if index == 1 then
			lg.line(px[index]+.5, py[index]+.5, mx+.5, my+.5)
			lg.setColor(1, 0, 0)
			lg.draw(pt[ptstyle], px[index] - 3, py[index] - 3)
		elseif index == #px + 1 then
			lg.line(px[index-1]+.5, py[index-1]+.5, mx+.5, my+.5)
			lg.setColor(1, 0, 0)
			lg.draw(pt[ptstyle], px[index-1] - 3, py[index-1] - 3)
		else
			lg.line(px[index-1]+.5, py[index-1]+.5, mx+.5, my+.5)
			lg.line(px[index]+.5, py[index]+.5, mx+.5, my+.5)
			lg.setColor(1, 0, 0)
			lg.draw(pt[ptstyle], px[index] - 3, py[index] - 3)
		end
	end
	lg.setColor(0, 0, 1)
	lg.draw(pt[ptstyle], mx - 3, my - 3)
	local mousestr = "("..mx..","..my..") " .. index .. "/" .. #px .. " " .. (issaved and "" or "modified")
	lg.pop()
	lg.setColor(0, 0, 0)
	lg.print(mousestr, scale*(mx+2)+1, scale*(my+2)+1)
	lg.setColor(1, 1, 1)
	lg.print(mousestr, scale*(mx+2), scale*(my+2))
end
