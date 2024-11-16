local enemyCollisionRadius = 30  -- Радиус отталкивания между врагами

EnemyManager = {
    enemies = {},
    enemyTypes = {
        "squid"  -- Можно добавлять новые типы врагов здесь
    }
}

function EnemyManager.initialize()
    EnemyManager.enemies = {}
    for i = 1, 50 do
        EnemyManager.createNewEnemy()
    end
end

function EnemyManager.createNewEnemy()
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
    
    local enemy = Squid.new(x, y)
    table.insert(EnemyManager.enemies, enemy)
end

function EnemyManager.update(dt, player)
    -- Сначала обновляем всех врагов
    for _, enemy in ipairs(EnemyManager.enemies) do
        enemy:update(dt, player)
    end
    
    -- Затем применяем отталкивание между врагами
    for i = 1, #EnemyManager.enemies do
        local enemy1 = EnemyManager.enemies[i]
        
        for j = i + 1, #EnemyManager.enemies do
            local enemy2 = EnemyManager.enemies[j]
            
            local dx = enemy2.x - enemy1.x
            local dy = enemy2.y - enemy1.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < enemyCollisionRadius and distance > 0 then
                local nx = dx / distance
                local ny = dy / distance
                local pushForce = (enemyCollisionRadius - distance) * 50
                
                enemy1.dx = enemy1.dx - nx * pushForce * dt
                enemy1.dy = enemy1.dy - ny * pushForce * dt
                enemy2.dx = enemy2.dx + nx * pushForce * dt
                enemy2.dy = enemy2.dy + ny * pushForce * dt
            end
        end
    end
    
    -- Наконец, обновляем позиции и проверяем урон от пуль
    for i = #EnemyManager.enemies, 1, -1 do
        local enemy = EnemyManager.enemies[i]
        
        -- Обновляем позицию
        enemy.x = enemy.x + enemy.dx * dt
        enemy.y = enemy.y + enemy.dy * dt
        
        -- Ограничиваем скорость
        local speed = math.sqrt(enemy.dx * enemy.dx + enemy.dy * enemy.dy)
        if speed > enemy.speed then
            local factor = enemy.speed / speed
            enemy.dx = enemy.dx * factor
            enemy.dy = enemy.dy * factor
        end
        
        -- Проверяем попадания пуль
        for j = #bullets, 1, -1 do
            local bullet = bullets[j]
            if checkCircleCollision(bullet.x, bullet.y, enemy.x, enemy.y, enemy.size) then
                enemy.health = enemy.health - 1
                table.remove(bullets, j)
                
                if enemy.health <= 0 then
                    score = score + enemy.score
                    table.remove(EnemyManager.enemies, i)
                    EnemyManager.createNewEnemy()
                    break
                end
            end
        end
    end
end

function EnemyManager.draw()
    for _, enemy in ipairs(EnemyManager.enemies) do
        enemy:draw()
    end
end