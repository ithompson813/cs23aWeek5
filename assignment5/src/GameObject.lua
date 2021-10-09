--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    -- whether or not to act a projectile
    -- default fields to false or 0
    self.projectile = false
    self.dx = 0
    self.dy = 0

    -- variables to track distance
    self.distanceTraveled = 0

    -- completed flag will be set true once object has flown far enough
    self.completed = false

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- default empty collision callback
    self.onCollide = function() end
end

function GameObject:update(dt)

    -- if the projectile flag has been triggered
    if self.projectile then

        -- move object
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt

        -- update distance traveled
        self.distanceTraveled = self.distanceTraveled + PLAYER_THROW_POWER * dt

        -- if object has traveled more than four tiles
        if self.distanceTraveled > (PLAYER_THROW_RANGE * TILE_SIZE) then

            -- flag object for deletion
            self.completed = true
        end

        -- check if projectile has reached a wall and delete on contact
        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then
            self.completed = true
        elseif self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.completed = true
        elseif self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then
            self.completed = true
        elseif self.y + self.height >= VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
        + MAP_RENDER_OFFSET_Y - TILE_SIZE then
            self.completed = true
        end

    end

end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end