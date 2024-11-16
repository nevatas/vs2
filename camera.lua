camera = {
    x = 0,
    y = 0
}

function updateCamera()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    camera.x = player.x - windowWidth / 2
    camera.y = player.y - windowHeight / 2
end