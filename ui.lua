require 'math'
require 'leaf.polygon'

ui = {}

ui.widgets = {}

local frame = 300
local knob_radius = 15
local uix, uiy = love.graphics.getWidth() - frame - 10, 200
local uiw = frame - 50
local active = nil

local function updateWidget (widget)
    p = (widget.val - widget.min) /  (widget.max - widget.min)
    widget.kx, widget.ky = (uiw - widget.x) * p, widget.y
end

local function interpretVal(widget, x)
    p = (x - uix - widget.x + knob_radius * 2) / uiw
    if p < 0 then p = 0
    elseif p > 1 then p = 1 end
    widget.val = widget.min + p * (widget.max - widget.min)
    if widget.int then
        widget.val = math.floor(widget.val)
    end
    updateWidget(widget)
end

local function addSlider(paramname, label, min, max, def, int)
    local x, y = 20, #ui.widgets * 80
    slider = {
        x = x,
        y = y,
        kx = 0,
        ky = 0,
        min = min,
        max = max,
        val = def,
        int = int,
        label = label,
        paramname = paramname
    }
    table.insert(ui.widgets, slider)
    updateWidget(slider)
    return slider
end

local genbutton = leaf.Rect:new(uix, love.graphics.getHeight() - 200, 
                                uix + uiw, love.graphics.getHeight() - 160)

function ui.load()
    addSlider('sources',        'Source Blocks',    1,   5,   1,   true)
    addSlider('miner_limit',    'Maximum Miners',   10,  2500,500, true)
    addSlider('fork_chance',    'Fork Rate',        0,   0.2, 0.1, false)
end

function ui.update(dt)
    if active and love.mouse.isDown('l') then
        interpretVal(active, love.mouse.getX())
    end
end

function ui.settings()
    local t = {}
    for i, widget in ipairs(ui.widgets) do
        t[widget.paramname] = widget.val
    end
    return t
end

function ui.draw()
    love.graphics.push()
        love.graphics.translate(uix, uiy)
        for i, widget in ipairs(ui.widgets) do
            -- Anchor
            love.graphics.setColor(128, 128, 128)
            love.graphics.setLineWidth(2)
            love.graphics.line(widget.x - knob_radius, widget.y, uiw - knob_radius, widget.y)
            -- Knob
            love.graphics.setColor(255, 255, 255)
            love.graphics.circle('fill', widget.kx, widget.ky, knob_radius, 30)
            -- Label
            love.graphics.printf(widget.label, widget.x - knob_radius, widget.y + 20, uiw, 'center')
            -- Value
            love.graphics.print(widget.val, widget.x + uiw - 20, widget.y - 4)
        end
    love.graphics.pop()

    -- Draw generate button
    love.graphics.rectangle('line', genbutton.left, genbutton.top, 
                            genbutton:getWidth(), genbutton:getHeight())
    love.graphics.printf('Generate (F4)', genbutton.left, genbutton.top + 10, 
                         genbutton:getWidth(), 'center')
end

function ui.mousepressed(x, y, button)
    for i, widget in ipairs(ui.widgets) do
        rect = leaf.Rect:new(uix + widget.kx - knob_radius, uiy + widget.ky - knob_radius,
                             uix + widget.kx + knob_radius, uiy + widget.ky + knob_radius)

        if rect:contains(x, y) then
            active = widget
        end
    end

    if genbutton:contains(x, y) then
        world:generate(ui.settings())
    end
end

function ui.mousereleased(x, y, button)
    active = nil
end