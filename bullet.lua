bullets = {}
bulletSpeed = 500
bulletSize = 10

function createBullet(screenX, screenY)
    local worldX = screenX + camera.x
    local worldY = screenY + camera.y
    
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

function updateBullets(dt)
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
end

function drawBullets()
    love.graphics.setColor(1, 1, 1) -- Белый цвет для пуль
    for _, bullet in ipairs(bullets) do
        love.graphics.circle('fill', bullet.x, bullet.y, bulletSize/2)
    end
end