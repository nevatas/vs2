effects = {
    fadeIn = {
        active = true,
        duration = 5,
        currentTime = 0,
        alpha = 1,
        startSound = nil,  -- Здесь будем хранить звук
        soundPlayed = false  -- Флаг, что звук уже проигран
    }
}

function initializeEffects()
    -- Загружаем звук
    effects.fadeIn.startSound = love.audio.newSource("sounds/start_sound.wav", "static")
end

function updateEffects(dt)
    if effects.fadeIn.active then
        -- Проигрываем звук только один раз в начале
        if not effects.fadeIn.soundPlayed then
            effects.fadeIn.startSound:play()
            effects.fadeIn.soundPlayed = true
        end
        
        effects.fadeIn.currentTime = effects.fadeIn.currentTime + dt
        
        -- Вычисляем текущую прозрачность
        effects.fadeIn.alpha = 1 - (effects.fadeIn.currentTime / effects.fadeIn.duration)
        
        -- Проверяем, закончился ли эффект
        if effects.fadeIn.currentTime >= effects.fadeIn.duration then
            effects.fadeIn.active = false
            effects.fadeIn.alpha = 0
        end
    end
end

function drawEffects()
    -- Рисуем затемнение поверх всего остального
    if effects.fadeIn.alpha > 0 then
        love.graphics.setColor(0, 0, 0, effects.fadeIn.alpha)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end
end