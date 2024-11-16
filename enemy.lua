enemies = {}
enemySpeed = 100
score = 0
enemySprite = nil
enemyCollisionRadius = 30  -- Радиус отталкивания между врагами

function initializeEnemies()
    enemySprite = love.graphics.newImage("assets/enemy/creature_001.png")
    
    enemies = {}
    for i = 1, 50 do
        createNewEnemy()
    end
end

function createNewEnemy()
    local side = love.math.random(1, 4)
    local x, y
    
    if side == 1 then -- верх
        x = love.math.random(0, gameWorld.width)
        y = -50
    elseif side == 2 then -- право
        x = gameWorld.width + 50
        y = love.math.random(0, gameWorld.height)
    elseif side == 3 then -- низ
        x = love.math.random(0, gameWorld.width)
        y = gameWorld.height + 50
    else -- лево
        x = -50
        y = love.math.random(0, gameWorld.height)
    end
    
    local enemy = {
        x = x,
        y = y,
        size = 20,
        dx = 0,  -- Добавляем вектор движения
        dy = 0
    }
    table.insert(enemies, enemy)
end

function updateEnemies(dt)
    -- Сначала вычисляем направление движения к игроку для каждого врага
    for _, enemy in ipairs(enemies) do
        local dx = player.x + player.size/2 - enemy.x
        local dy = player.y + player.size/2 - enemy.y
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then
            enemy.dx = dx / length * enemySpeed
            enemy.dy = dy / length * enemySpeed
        end
    end
    
    -- Затем применяем отталкивание между врагами
    for i = 1, #enemies do
        local enemy1 = enemies[i]
        
        -- Проверяем столкновения с другими врагами
        for j = i + 1, #enemies do
            local enemy2 = enemies[j]
            
            local dx = enemy2.x - enemy1.x
            local dy = enemy2.y - enemy1.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- Если враги слишком близко друг к другу
            if distance < enemyCollisionRadius and distance > 0 then
                -- Нормализуем вектор расстояния
                local nx = dx / distance
                local ny = dy / distance
                
                -- Сила отталкивания обратно пропорциональна расстоянию
                local pushForce = (enemyCollisionRadius - distance) * 50
                
                -- Применяем силу отталкивания к обоим врагам
                enemy1.dx = enemy1.dx - nx * pushForce * dt
                enemy1.dy = enemy1.dy - ny * pushForce * dt
                enemy2.dx = enemy2.dx + nx * pushForce * dt
                enemy2.dy = enemy2.dy + ny * pushForce * dt
            end
        end
    end
    
    -- Наконец, обновляем позиции всех врагов
    for _, enemy in ipairs(enemies) do
        -- Обновляем позицию с учетом всех сил
        enemy.x = enemy.x + enemy.dx * dt
        enemy.y = enemy.y + enemy.dy * dt
        
        -- Ограничиваем скорость врага
        local speed = math.sqrt(enemy.dx * enemy.dx + enemy.dy * enemy.dy)
        if speed > enemySpeed then
            local factor = enemySpeed / speed
            enemy.dx = enemy.dx * factor
            enemy.dy = enemy.dy * factor
        end
    end
end

function drawEnemies()
    love.graphics.setColor(1, 1, 1, 1)
    for _, enemy in ipairs(enemies) do
        love.graphics.draw(
            enemySprite,
            enemy.x - enemySprite:getWidth()/2,
            enemy.y - enemySprite:getHeight()/2
        )
    end
    
    -- Для отладки можно раскомментировать, чтобы увидеть радиус коллизий
    --[[
    love.graphics.setColor(1, 0, 0, 0.2)
    for _, enemy in ipairs(enemies) do
        love.graphics.circle('line', enemy.x, enemy.y, enemyCollisionRadius/2)
    end
    --]]
end