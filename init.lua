
function love.load()
    floor = {}
    floor.color = {0x33, 0x04, 0x4b, 0xff}
    floor.height = 32

    background = {}
    background.color = {0xca, 0x7e, 0xbc, 0xff}

    screen = {}
    screen.width = 128
    screen.height = 128
    screen.canvas = love.graphics.newCanvas(screen.width, screen.height)
    screen.canvas:setFilter('nearest', 'nearest')

    local w, h = love.graphics.getDimensions()
    if w > h then
        screen.scale = h/screen.height
        screen.x = (w-h)/2
        screen.y = 0
    else
        screen.scale = w/screen.width
        screen.x = 0
        screen.y = (h-w)/2
    end

    rain = {}
    rain.color = {0xee, 0xc3, 0x00, 0xff}
    rain.intensity = 0.01
    rain.length = 6
    rain.angle = math.rad(30) -- 0 is downwards
    rain.dx = -rain.length*math.sin(rain.angle)
    rain.dy = -rain.length*math.cos(rain.angle)
    rain.drops = {}
    rain.count = rain.intensity*screen.width * screen.height/rain.length
    rain.speed = 160
    rain.splash = {}
    rain.splash_time = 0.25

    for i = 1, rain.count do
        drop = {}
        drop.x = math.random(0, screen.width)
        drop.y = math.random(0, screen.height)

        rain.drops[i] = drop
    end
end

function love.update(dt)
    for _, drop in ipairs(rain.drops) do
        local sp = 1/rain.length*rain.speed*dt

        drop.x = drop.x + rain.dx*sp
        drop.y = drop.y - rain.dy*sp

        if drop.x < 0 then drop.x = drop.x + screen.width end
        if drop.x >= screen.width then drop.x = drop.x - screen.width end
        if drop.y >= screen.height-floor.height*math.random()+rain.dy then
            table.insert(rain.splash, {x = math.floor(drop.x + rain.dx),
                                       y = math.floor(drop.y - rain.dy),
                                       t = rain.splash_time})
            drop.y = drop.y - screen.height + floor.height - rain.length
        end
    end

    for _, drop in ipairs(rain.splash) do
        drop.t = drop.t - dt
    end
end

function love.draw()
    love.graphics.setCanvas(screen.canvas)
        love.graphics.setBlendMode('alpha')
        love.graphics.clear(background.color)

        love.graphics.setColor(floor.color)
        love.graphics.rectangle('fill', 0, screen.height-floor.height,
                                screen.width, floor.height)

        love.graphics.setLineWidth(0.6)
        love.graphics.setLineStyle('rough')
        love.graphics.setColor(rain.color)
        for _, drop in ipairs(rain.drops) do
            love.graphics.line(drop.x, drop.y,
                               drop.x + rain.dx, drop.y - rain.dy)
        end

        for i, drop in ipairs(rain.splash) do
            local stage = math.ceil((rain.splash_time-drop.t)
                                    * (3/rain.splash_time))

            if stage == 1 then
                love.graphics.points(drop.x,   drop.y-1,
                                     drop.x+1, drop.y,
                                     drop.x,   drop.y+1,
                                     drop.x-1, drop.y)
            elseif stage == 2 then
                love.graphics.points(drop.x,   drop.y-2,
                                     drop.x+2, drop.y,
                                     drop.x,   drop.y+2,
                                     drop.x-2, drop.y,
                                     drop.x+1, drop.y+1,
                                     drop.x-1, drop.y+1,
                                     drop.x-1, drop.y-1,
                                     drop.x+1, drop.y-1)

            elseif stage == 3 then
                love.graphics.points(drop.x,   drop.y-2,
                                     drop.x+2, drop.y,
                                     drop.x,   drop.y+2,
                                     drop.x-2, drop.y)
            else
                table.remove(rain.splash, i)
            end
        end
    love.graphics.setCanvas()

    love.graphics.setBlendMode('alpha')
    love.graphics.clear(0, 0, 0, 255)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(screen.canvas, screen.x, screen.y, 0, screen.scale)
end
