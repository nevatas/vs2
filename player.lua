player = {
    x = 0,
    y = 0,
    size = 50,
    speed = 300,
    maxHp = 100,
    hp = 100,
    damageTimer = 0,
    damageInterval = 0.5,
    sprite = nil,
    scale = 1,
    shootTimer = 0,    -- Таймер для стрельбы
    shootInterval = 0.5 -- Интервал между выстрелами (2 раза в секунду)
}

function initializePlayer()
    player.sprite = love.graphics.newImage("assets/player.png")
    player.scale = player.size / player.sprite:getWidth()
    player.x = gameWorld.width / 2
    player.y = gameWorld.height / 2
end

function updatePlayer(dt)
    player.damageTimer = math.max(0, player.damageTimer - dt)
    player.shootTimer = math.max(0, player.shootTimer - dt)
    
    -- Получаем позицию курсора в мировых координатах
    local mouseX = love.mouse.getX() + camera.x
    local mouseY = love.mouse.getY() + camera.y
    
    -- Вычисляем направление к курсору
    local dx = mouseX - (player.x + player.size/2)
    local dy = mouseY - (player.y + player.size/2)
    local length = math.sqrt(dx * dx + dy * dy)
    
    -- Двигаемся в направлении курсора только если он достаточно далеко
    if length > 5 then  -- Небольшой порог, чтобы избежать дрожания
        dx = dx / length
        dy = dy / length
        
        player.x = math.max(0, math.min(player.x + dx * player.speed * dt, gameWorld.width - player.size))
        player.y = math.max(0, math.min(player.y + dy * player.speed * dt, gameWorld.height - player.size))
    end
    
    -- Автоматическая стрельба
    if player.shootTimer <= 0 then
        -- Находим ближайшего врага
        local nearestEnemy = findNearestEnemy()
        if nearestEnemy then
            -- Создаем пулю в направлении ближайшего врага
            local playerCenterX = player.x + player.size/2
            local playerCenterY = player.y + player.size/2
            local angle = math.atan2(
                nearestEnemy.y - playerCenterY,
                nearestEnemy.x - playerCenterX
            )
            
            local bullet = {
                x = playerCenterX,
                y = playerCenterY,
                dx = math.cos(angle) * bulletSpeed,
                dy = math.sin(angle) * bulletSpeed
            }
            table.insert(bullets, bullet)
            player.shootTimer = player.shootInterval
        end
    end
    
    -- Проверка получения урона
    if player.damageTimer == 0 then
        for _, enemy in ipairs(EnemyManager.enemies) do
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

function findNearestEnemy()
    local nearestEnemy = nil
    local minDistance = math.huge
    local playerCenterX = player.x + player.size/2
    local playerCenterY = player.y + player.size/2
    
    for _, enemy in ipairs(EnemyManager.enemies) do
        local dx = enemy.x - playerCenterX
        local dy = enemy.y - playerCenterY
        local distance = dx * dx + dy * dy
        
        if distance < minDistance then
            minDistance = distance
            nearestEnemy = enemy
        end
    end
    
    return nearestEnemy
end

function drawPlayer()
    if player.damageTimer > 0 then
        love.graphics.setColor(1, 0, 0, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    love.graphics.draw(
        player.sprite,
        player.x + player.size/2,
        player.y + player.size/2,
        0,
        player.scale,
        player.scale,
        player.sprite:getWidth()/2,
        player.sprite:getHeight()/2
    )
end