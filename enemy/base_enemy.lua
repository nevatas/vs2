-- enemy/base_enemy.lua
BaseEnemy = {}
BaseEnemy.__index = BaseEnemy

function BaseEnemy.new(x, y)
    local self = setmetatable({}, BaseEnemy)
    self.x = x
    self.y = y
    self.size = 20
    self.speed = 100
    self.dx = 0
    self.dy = 0
    self.health = 1
    self.score = 1
    self.sprite = nil
    return self
end

function BaseEnemy:update(dt, player)
    -- Базовое движение к игроку
    local dx = player.x + player.size/2 - self.x
    local dy = player.y + player.size/2 - self.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then
        self.dx = dx / length * self.speed
        self.dy = dy / length * self.speed
    end
end

function BaseEnemy:draw()
    if self.sprite then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            self.sprite,
            self.x - self.sprite:getWidth()/2,
            self.y - self.sprite:getHeight()/2
        )
    end
end