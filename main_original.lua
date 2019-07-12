-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

--Seed the rng
math.randomseed(os.time())

-- Initialize variables
local lives = 3
local score = 0
local died = false
 
local enemyTable = {}
 
local player
local gameLoopTimer
local livesText
local scoreText

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the player, asteroids, lasers, etc.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

-- Load the background
local background = display.newImageRect( backGroup, "tr.jpg", 508, 1100 )
background.x = display.contentCenterX
background.y = display.contentCenterY
background.fill.effect = "filter.desaturate"
 
background.fill.effect.intensity = 0.8

player = display.newImageRect( mainGroup, "tr.png", 100, 128 )
player.x = display.contentCenterX
player.y = display.contentHeight - 100
physics.addBody( player, { radius=30, isSensor=true } )
player.myName = "player"

-- Display lives and score
livesText = display.newText( uiGroup, "Lives: " .. lives, 220, 80, "KGDoYouLoveMe.ttf", 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 500, 80, "KGDoYouLoveMe.ttf", 36 )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function createEnemy()
    local newEnemy = display.newImageRect( mainGroup, "paper.png" ,98, 79 )
    table.insert( enemyTable, newEnemy )
    physics.addBody( newEnemy, "dynamic", { radius=40, bounce=0.8 } )
    newEnemy.myName = "enemy"

    newEnemy.x = math.random( display.contentWidth )
    newEnemy.y = -60
    newEnemy:setLinearVelocity( math.random( -20,20 ), math.random( 150,400 ) )

    newEnemy:applyTorque( math.random( -6,6 ) )
end


local function fireBullet()
 
    local newBullet = display.newImageRect( mainGroup, "rock.png", 14, 40 )
    physics.addBody( newBullet, "dynamic", { isSensor=true } )
    newBullet.isBullet = true
    newBullet.myName = "bullet"

    newBullet.x = player.x
    newBullet.y = player.y
    newBullet:toBack()
    transition.to( newBullet, { y=-40, time=500, 
        onComplete = function() display.remove( newBullet ) end
    } )
end

player:addEventListener( "tap", fireBullet )


local function dragPlayer(event)
    local player = event.target
    local phase = event.phase

    if ( "began" == phase ) then
        -- Set touch focus on the player
        display.currentStage:setFocus( player )
        -- Store initial offset position
        player.touchOffsetX = event.x - player.x
        player.touchOffsetY = event.y - player.y

    elseif ( "moved" == phase ) then
            -- Move the player to the new touch position
            player.x = event.x - player.touchOffsetX
            player.y = event.y - player.touchOffsetY

    elseif ( "ended" == phase or "cancelled" == phase ) then
            -- Release touch focus on the player
            display.currentStage:setFocus( nil )
    end

    return true  -- Prevents touch propagation to underlying objects

end

player:addEventListener( "touch", dragPlayer )

local function gameLoop()

    --create new enemy
    createEnemy()

    -- Remove asteroids which have drifted off screen
    for i = #enemyTable, 1, -1 do
        local thisEnemy = enemyTable[i]
 
        if ( thisEnemy.x < -100 or
             thisEnemy.x > display.contentWidth + 100 or
             thisEnemy.y < -100 or
             thisEnemy.y > display.contentHeight + 100 )
        then
            display.remove( thisEnemy )
            table.remove( enemyTable, i )
        end
    end
end

gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 0 )

local function restorePlayer()
 
    player.isBodyActive = false
    player.x = display.contentCenterX
    player.y = display.contentHeight - 100
 
    -- Fade in the player
    transition.to( player, { alpha=1, time=4000,
        onComplete = function()
            player.isBodyActive = true
            died = false
        end
    } )
end

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "bullet" and obj2.myName == "enemy" ) or
             ( obj1.myName == "enemy" and obj2.myName == "bullet" ) )
        then
            
            -- Remove both the bullet and enemy
            display.remove( obj1 )
            display.remove( obj2 )

            for i = #enemyTable, 1, -1 do
                if ( enemyTable[i] == obj1 or enemyTable[i] == obj2 ) then
                    table.remove( enemyTable, i )
                    break
                end
            end

            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score


        elseif ( ( obj1.myName == "player" and obj2.myName == "enemy" ) or
            ( obj1.myName == "enemy" and obj2.myName == "player" ) )   
        then
            if ( died == false ) then
                died = true

                 -- Update lives
                 lives = lives - 1
                 livesText.text = "Lives: " .. lives

                if ( lives == 0 ) then
                    display.remove( player )
                else
                    player.alpha = 0
                    timer.performWithDelay( 1000, restorePlayer )
                end
            end

        end
    end
end

Runtime:addEventListener( "collision", onCollision )