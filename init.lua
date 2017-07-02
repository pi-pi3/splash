
function love.load()
    floor = {}
    floor.color = {0x33, 0x04, 0x4b, 0xff}
    floor.height = 32

    screen = {}
    screen.width = 128
    screen.height = 128
    screen.rain_canvas = love.graphics.newCanvas(screen.width, screen.height)
    screen.rain_canvas:setFilter('nearest', 'nearest')
    screen.star_canvas = love.graphics.newCanvas(screen.width, screen.height)
    screen.star_canvas:setFilter('nearest', 'nearest')

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
    rain.background = {0xca, 0x7e, 0xbc, 0xff}
    rain.color = {0xee, 0xc3, 0x00, 0xff}
    rain.intensity = 0.1
    rain.length = 6
    rain.angle = math.rad(30) -- 0 is downwards
    rain.dx = -rain.length*math.sin(rain.angle)
    rain.dy = -rain.length*math.cos(rain.angle)
    rain.drops = {}
    rain.count = rain.intensity*screen.width
               * rain.intensity*screen.height/rain.length
    rain.speed = 160
    rain.splash = {}
    rain.splash_time = 0.25

    for i = 1, rain.count do
        drop = {}
        drop.x = math.random(0, screen.width)
        drop.y = math.random(0, screen.height)

        rain.drops[i] = drop
    end

    stars = {}
    stars.background = {0x02, 0x0c, 0x24, 0xff}
    stars.color = {0xee, 0xc3, 0x00, 0xff}
    stars.intensity = 0.05
    stars.stars = {}
    stars.count = stars.intensity*screen.width * 
                  stars.intensity*screen.height
    stars.flash_time = 0.35

    local sectors = math.sqrt(stars.count)
    local w = screen.width/sectors
    local h = screen.height/sectors
    local s = {}

    for i = 1, stars.count do
        local x, y
        local good
        while not good do
            x = math.random(0, sectors)
            y = math.random(0, sectors)

            if not s[y] then
                s[y] = {[x] = true}
                good = true
            elseif not s[y][x] then
                s[y][x] = true
                good = true
            end
        end

        star = {}
        star.x = x*w + math.random(0, w*0.7)
        star.y = y*h + math.random(0, h*0.7)
        star.t = 0

        stars.stars[i] = star
    end

    rain.duration = 1.5
    star.duration = 1.5

    seq = {star, rain}
    frame = 1
end

function love.update(dt)
    seq[frame].duration = seq[frame].duration - dt
    if seq[frame].duration <= 0 then
        frame = frame + 1
    end

    if frame > #seq then
        love.event.quit()
    end

    if frame == 1 then
        for _, star in ipairs(stars.stars) do
            star.t = math.fmod(star.t + dt, stars.flash_time)
        end
    elseif frame == 2 then
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
end

function draw_rain()
    love.graphics.setBlendMode('alpha')
    love.graphics.clear(rain.background)

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
end

function draw_stars()
    love.graphics.setBlendMode('alpha')
    love.graphics.clear(stars.background)

    love.graphics.setColor(stars.color)
    for _, star in ipairs(stars.stars) do
        local stage = math.ceil(star.t * (2/stars.flash_time))

        if stage == 1 then
            love.graphics.points(star.x,   star.y-1,
                                 star.x+1, star.y,
                                 star.x,   star.y+1,
                                 star.x-1, star.y)
        elseif stage == 2 then
            love.graphics.points(star.x,   star.y-2,
                                 star.x+2, star.y,
                                 star.x,   star.y+2,
                                 star.x-2, star.y)
        end
    end
end

function love.draw()
    if frame == 1 then
        love.graphics.setCanvas(screen.star_canvas)

        draw_stars()

        love.graphics.setCanvas()

        love.graphics.setBlendMode('alpha')
        love.graphics.clear(0, 0, 0, 255)
        love.graphics.setColor(255, 255, 255, 255)

        love.graphics.draw(screen.star_canvas, screen.x, screen.y,
                           0, screen.scale)
    elseif frame == 2 then
        love.graphics.setCanvas(screen.rain_canvas)

        draw_rain()

        love.graphics.setCanvas()

        love.graphics.setBlendMode('alpha')
        love.graphics.clear(0, 0, 0, 255)
        love.graphics.setColor(255, 255, 255, 255)

        love.graphics.draw(screen.rain_canvas, screen.x, screen.y,
                           0, screen.scale)
    end
end
