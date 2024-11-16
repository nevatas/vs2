function love.load()
    -- Размеры игрового мира
    gameWorld = {
        width = 2000,
        height = 2000
    }
    
    -- Игрок
    player = {
        x = gameWorld.width / 2,
        y = gameWorld.height / 2,
        size = 50,
        speed = 300,
        maxHp = 100,
        hp = 100,
        damageTimer = 0,
        damageInterval = 0.5
    }
    
    -- Собираемый квадратик (powerup)
    powerup = {
        x = love.math.random(100, gameWorld.width - 100),
        y = love.math.random(100, gameWorld.height - 100),
        size = 30,
        collected = false
    }
    
    -- Вращающийся защитник
    guardian = {
        active = false,
        size = 20,
        distance = 60,  -- Расстояние от игрока
        angle = 0,
        rotationSpeed = 5  -- Скорость вращения в радианах в секунду
    }
    
    -- Камера
    camera = {
        x = 0,
        y = 0
    }
    
    -- Враги
    enemies = {}
    enemySpeed = 100
    score = 0
    
    -- Пули
    bullets = {}
    bulletSpeed = 500
    bulletSize = 10
    
    -- Создаём начальных врагов
    for i = 1, 50 do
        createNewEnemy()
    end
    
    font = love.graphics.newFont(24)
    love.graphics.setFont(font)
end

function createNewEnemy()
    local side = love.math.random(1, 4)
    local x, y
    
    if side == 1 then
        x = love.math.random(0, gameWorld.width)
        y = -50
    elseif side == 2 then
        x = gameWorld.width + 50
        y = love.math.random(0, gameWorld.height)
    elseif side == 3 then
        x = love.math.random(0, gameWorld.width)
        y = gameWorld.height + 50
    else
        x = -50
        y = love.math.random(0, gameWorld.height)
    end
    
    local enemy = {
        x = x,
        y = y,
        size = 20
    }
    table.insert(enemies, enemy)
end

function createBullet(targetX, targetY)
    local worldX = targetX + camera.x
    local worldY = targetY + camera.y
    
    local centerX = player.x + player.size/2
    local centerY = player.y + player.size/2
    
    local angle = math.atan2(worldY - centerY, worldX - centerX)
    
    local bullet = {
        x = centerX,
        y = centerY,
        dx = math.cos(angle) * bulletSpeed,
        dy = math.sin(angle) * bulletSpeed
    }
    table.insert(bullets, bullet)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        createBullet(x, y)
    end
end

function updateCamera()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    camera.x = player.x - windowWidth / 2
    camera.y = player.y - windowHeight / 2
end

function checkCircleCollision(pointX, pointY, circleX, circleY, radius)
    local dx = pointX - circleX
    local dy = pointY - circleY
    return (dx * dx + dy * dy) <= (radius * radius)
end

function love.update(dt)
    player.damageTimer = math.max(0, player.damageTimer - dt)
    
    -- Движение игрока
    local dx = 0
    local dy = 0
    
    if love.keyboard.isDown('right') then dx = dx + 1 end
    if love.keyboard.isDown('left') then dx = dx - 1 end
    if love.keyboard.isDown('down') then dy = dy + 1 end
    if love.keyboard.isDown('up') then dy = dy - 1 end
    
    if dx ~= 0 and dy ~= 0 then
        local length = math.sqrt(dx * dx + dy * dy)
        dx = dx / length
        dy = dy / length
    end
    
    player.x = math.max(0, math.min(player.x + dx * player.speed * dt, gameWorld.width - player.size))
    player.y = math.max(0, math.min(player.y + dy * player.speed * dt, gameWorld.height - player.size))
    
    updateCamera()
    
    -- Проверка подбора powerup
    if not powerup.collected and checkCollision(
        player.x, player.y, player.size, player.size,
        powerup.x, powerup.y, powerup.size, powerup.size
    ) then
        powerup.collected = true
        guardian.active = true
    end
    
    -- Обновление вращающегося защитника
    if guardian.active then
        guardian.angle = guardian.angle + guardian.rotationSpeed * dt
        -- Вычисляем позицию защитника относительно центра игрока
        guardian.x = player.x + player.size/2 + math.cos(guardian.angle) * guardian.distance - guardian.size/2
        guardian.y = player.y + player.size/2 + math.sin(guardian.angle) * guardian.distance - guardian.size/2
        
        -- Проверяем столкновения защитника с врагами
        for i = #enemies, 1, -1 do
            if checkCollision(
                guardian.x, guardian.y, guardian.size, guardian.size,
                enemies[i].x - enemies[i].size, enemies[i].y - enemies[i].size,
                enemies[i].size * 2, enemies[i].size * 2
            ) then
                table.remove(enemies, i)
                score = score + 1
                createNewEnemy()
            end
        end
    end
    
    -- Обновление врагов
    for _, enemy in ipairs(enemies) do
        local dx = player.x + player.size/2 - enemy.x
        local dy = player.y + player.size/2 - enemy.y
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then
            dx = dx / length
            dy = dy / length
            enemy.x = enemy.x + dx * enemySpeed * dt
            enemy.y = enemy.y + dy * enemySpeed * dt
        end
    end
    
    -- Обновление пуль
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.x = bullet.x + bullet.dx * dt
        bullet.y = bullet.y + bullet.dy * dt
        
        if bullet.x < 0 or bullet.x > gameWorld.width or
           bullet.y < 0 or bullet.y > gameWorld.height then
            table.remove(bullets, i)
        else
            local bulletHit = false
            for j = #enemies, 1, -1 do
                local enemy = enemies[j]
                if checkCircleCollision(bullet.x, bullet.y, enemy.x, enemy.y, enemy.size) then
                    table.remove(enemies, j)
                    bulletHit = true
                    score = score + 1
                    createNewEnemy()
                    break
                end
            end
            if bulletHit then
                table.remove(bullets, i)
            end
        end
    end
    
    -- Проверка столкновений с врагами
    if player.damageTimer == 0 then
        for _, enemy in ipairs(enemies) do
            if checkCollision(
                player.x, player.y, player.size, player.size,
                enemy.x - enemy.size, enemy.y - enemy.size,
                enemy.size * 2, enemy.size * 2
            ) then
                player.hp = player.hp - 1
                player.damageTimer = player.damageInterval
                if player.hp <= 0 then
                    love.event.quit()
                end
                break
            end
        end
    end
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)
    
    -- Рисуем границы игрового мира
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('line', 0, 0, gameWorld.width, gameWorld.height)
    
    -- Рисуем powerup если не собран
    if not powerup.collected then
        love.graphics.setColor(0, 1, 0)  -- Зеленый цвет
        love.graphics.rectangle('fill', powerup.x, powerup.y, powerup.size, powerup.size)
    end
    
    -- Рисуем вращающийся защитник
    if guardian.active then
        love.graphics.setColor(0, 1, 0)  -- Зеленый цвет
        love.graphics.rectangle('fill', guardian.x, guardian.y, guardian.size, guardian.size)
    end
    
    -- Рисуем игрока
    if player.damageTimer > 0 then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 0, 1)
    end
    love.graphics.rectangle('fill', player.x, player.y, player.size, player.size)
    
    -- Рисуем пули
    love.graphics.setColor(1, 1, 0)
    for _, bullet in ipairs(bullets) do
        love.graphics.circle('fill', bullet.x, bullet.y, bulletSize/2)
    end
    
    -- Рисуем врагов
    love.graphics.setColor(0, 1, 0)
    for _, enemy in ipairs(enemies) do
        love.graphics.circle('fill', enemy.x, enemy.y, enemy.size)
    end
    
    love.graphics.pop()
    
    -- Интерфейс
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 5, 5, 210, 120)
    
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