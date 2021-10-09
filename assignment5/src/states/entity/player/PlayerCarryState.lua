--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerCarryState = Class{__includes = EntityWalkState}

local pickupAnimationFinished = false

function PlayerCarryState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerCarryState:enter(params)

    -- track which object player is carrying
    self.carriedObject = params.carriedObject

    -- don't allow player to control until animation is finished
    pickupAnimationFinished = false

    -- play pickup animation for current player position
    self.entity:changeAnimation('pickup-' .. tostring(self.entity.direction))

    -- after animation concludes
    Timer.after(.3, function()

        -- change to carrying animation
        self.entity:changeAnimation('carry-' .. tostring(self.entity.direction))

        -- allow player to move
        pickupAnimationFinished = true

    end)

end

function PlayerCarryState:update(dt)

    -- move object to above player's head
    self.carriedObject.x = self.entity.x - 1
    self.carriedObject.y = self.entity.y - (self.carriedObject.height / 2) - 1

    -- player may move just the same as walkState, but with a different animation
    if pickupAnimationFinished then
        if love.keyboard.isDown('left') then
            self.entity.direction = 'left'
            self.entity:changeAnimation('carry-left')
        elseif love.keyboard.isDown('right') then
            self.entity.direction = 'right'
            self.entity:changeAnimation('carry-right')
        elseif love.keyboard.isDown('up') then
            self.entity.direction = 'up'
            self.entity:changeAnimation('carry-up')
        elseif love.keyboard.isDown('down') then
            self.entity.direction = 'down'
            self.entity:changeAnimation('carry-down')
        else
            self.entity:changeAnimation('carry-idle-' .. tostring(self.entity.direction))
            self.entity.walkSpeed = 0
        end
    end

    -- instead of swing the sword, pressing space will throw the object
    if love.keyboard.wasPressed('space') then

        -- triggering the projectile flag will cause the projectile behavior to execute
        -- projectile behavior can be found in the GameObject file
        self.carriedObject.projectile = true

        -- determine movement and tracking variables based on directiom
        if self.entity.direction == 'right' then

            -- direction
            self.carriedObject.dx = PLAYER_THROW_POWER
            self.carriedObject.dy = 0

            -- move object to start from player's center mass
            self.carriedObject.x = self.entity.x + self.entity.width + 1
            self.carriedObject.y = self.entity.y

        elseif self.entity.direction == 'left' then

            -- direction
            self.carriedObject.dx = -PLAYER_THROW_POWER
            self.carriedObject.dy = 0

            -- move object to start from player's center mass
            self.carriedObject.x = self.entity.x - self.entity.width - 1
            self.carriedObject.y = self.entity.y

        elseif self.entity.direction == 'up' then

            -- direction
            self.carriedObject.dx = 0
            self.carriedObject.dy = -PLAYER_THROW_POWER

            -- moving object to start from player's center mass is not neccessary 
            -- when throwing upwards as pot is already in the correct position


        elseif self.entity.direction == 'down' then

            -- direction
            self.carriedObject.dx = 0
            self.carriedObject.dy = PLAYER_THROW_POWER

            -- move object to start from player's center mass
            self.carriedObject.x = self.entity.x
            self.carriedObject.y = self.entity.y + self.carriedObject.height

        end

        -- return player to walk state
        self.entity:changeState('walk')
    end


    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)

    -- if we bumped something when checking collision, check any object collisions
    if self.bumped then
        if self.entity.direction == 'left' then
            
            -- temporarily adjust position into the wall, since bumping pushes outward
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
            
            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-left')
                end
            end

            -- readjust
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'right' then
            
            -- temporarily adjust position
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
            
            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-right')
                end
            end

            -- readjust
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'up' then
            
            -- temporarily adjust position
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
            
            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-up')
                end
            end

            -- readjust
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
        else
            
            -- temporarily adjust position
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
            
            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-down')
                end
            end

            -- readjust
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
        end
    end
end