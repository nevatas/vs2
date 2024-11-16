require 'player'
require 'enemy'
require 'powerup'
require 'bullet'
require 'camera'
require 'collision'

function love.load()
    -- Размеры игрового мира
    gameWorld = {
        width = 2000,
        height = 2000
    }
    
    -- Инициализация всех систем
    initializePlayer()
    initializePowerup()
    initializeEnemies()
    
    -- Инициализация шрифта
    font = love.graphics.newFont(24)
    love.graphics.setFont(font)
end

function love.update(dt)
    updatePlayer(dt)
    updatePowerup(dt)
    updateEnemies(dt)
    updateBullets(dt)
    updateCamera()
end

function love.mousepressed(x, y, button)
    if button == 1 then
        createBullet(x, y)
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)
    
    -- Рисуем границы игрового мира
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('line', 0, 0, gameWorld.width, gameWorld.height)
    
    drawPowerup()
    drawEnemies()
    drawBullets()
    drawPlayer()
    
    love.graphics.pop()
    
    -- Интерфейс
    drawInterface()
end

function drawInterface()
    -- Фон интерфейса
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 5, 5, 210, 120)
    
    -- Текст и полоска HP
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("HP: " .. player.hp .. "/" .. player.maxHp, 10, 40)
    
    -- Полоска здоровья
    local hpBarWidth = 200
    local hpBarHeight = 20
    local x = 10
    local y = 70
    
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('fill', x, y, hpBarWidth, hpBarHeight)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', x, y, (player.hp / player.maxHp) * hpBarWidth, hpBarHeight)
end