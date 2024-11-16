powerup = {
    x = 0,
    y = 0,
    size = 30,
    collected = false
}

guardian = {
    active = false,
    size = 20,
    distance = 60,
    angle = 0,
    rotationSpeed = 5,
    x = 0,
    y = 0
}

function initializePowerup()
    powerup.x = love.math.random(100, gameWorld.width - 100)
    powerup.y = love.math.random(100, gameWorld.height - 100)
    powerup.collected = false
    guardian.active = false
end

function updatePowerup(dt)
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
        guardian.x = player.x + player.size/2 + math.cos(guardian.angle) * guardian.distance - guardian.size/2
        guardian.y = player.y + player.size/2 + math.sin(guardian.angle) * guardian.distance - guardian.size/2
        
        -- Проверка столкновений защитника с врагами
        for i = #EnemyManager.enemies, 1, -1 do
            local enemy = EnemyManager.enemies[i]
            if checkCollision(
                guardian.x, guardian.y, guardian.size, guardian.size,
                enemy.x - enemy.size, enemy.y - enemy.size,
                enemy.size * 2, enemy.size * 2
            ) then
                table.remove(EnemyManager.enemies, i)
                score = score + enemy.score
                EnemyManager.createNewEnemy()
            end
        end
    end
end

function drawPowerup()
    if not powerup.collected then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle('fill', powerup.x, powerup.y, powerup.size, powerup.size)
    end
    
    if guardian.active then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle('fill', guardian.x, guardian.y, guardian.size, guardian.size)
    end
end