player = {
    x = 0,
    y = 0,
    size = 50,  -- Это теперь будет использоваться для коллизий
    speed = 300,
    maxHp = 100,
    hp = 100,
    damageTimer = 0,
    damageInterval = 0.5,
    sprite = nil,  -- Здесь будем хранить спрайт
    scale = 1      -- Масштаб спрайта, настройте под свои нужды
}

function initializePlayer()
    -- Загружаем спрайт игрока
    player.sprite = love.graphics.newImage("assets/player.png")
    
    -- Вычисляем масштаб, чтобы спрайт соответствовал желаемому размеру
    player.scale = player.size / player.sprite:getWidth()
    
    player.x = gameWorld.width / 2
    player.y = gameWorld.height / 2
end

function updatePlayer(dt)
    player.damageTimer = math.max(0, player.damageTimer - dt)
    
    -- Движение игрока
    local dx = 0
    local dy = 0
    
    if love.keyboard.isDown('right') then dx = dx + 1 end
    if love.keyboard.isDown('left') then dx = dx - 1 end
    if love.keyboard.isDown('down') then dy = dy + 1 end
    if love.keyboard.isDown('up') then dy = dy - 1 end
    
    -- Нормализация диагонального движения
    if dx ~= 0 and dy ~= 0 then
        local length = math.sqrt(dx * dx + dy * dy)
        dx = dx / length
        dy = dy / length
    end
    
    player.x = math.max(0, math.min(player.x + dx * player.speed * dt, gameWorld.width - player.size))
    player.y = math.max(0, math.min(player.y + dy * player.speed * dt, gameWorld.height - player.size))
    
    -- Проверка получения урона
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

function drawPlayer()
    -- Устанавливаем цвет наложения при получении урона
    if player.damageTimer > 0 then
        love.graphics.setColor(1, 0, 0, 1)  -- Красный оттенок при уроне
    else
        love.graphics.setColor(1, 1, 1, 1)  -- Обычный цвет
    end
    
    -- Рисуем спрайт игрока
    love.graphics.draw(
        player.sprite,
        player.x + player.size/2,  -- Центрируем спрайт по X
        player.y + player.size/2,  -- Центрируем спрайт по Y
        0,                         -- Поворот (в радианах)
        player.scale,              -- Масштаб по X
        player.scale,              -- Масштаб по Y
        player.sprite:getWidth()/2,  -- Точка поворота X (центр спрайта)
        player.sprite:getHeight()/2   -- Точка поворота Y (центр спрайта)
    )
end