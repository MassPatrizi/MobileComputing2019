
local composer = require( "composer" )

local scene = composer.newScene()

local thirdDeathSound
local death
local shot
local explosion
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )


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
local backGroup  -- Display group for the background image
local mainGroup   -- Display group for the player, asteroids, lasers, etc.
local uiGroup   -- Display group for UI objects like the score

-- Plugins

local isPlay = true




local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function createEnemy()
    -- local redCollisionFilter = { groupIndex = -2 }
    local newEnemy = display.newImageRect( mainGroup, "asteroid.png", 90, 90 )
    table.insert( enemyTable, newEnemy )
    physics.addBody( newEnemy, "dynamic", { radius=40, bounce=0} ) -- , filter = {maskBits = 2, categoryBits = 2}
    newEnemy.myName = "enemy"

    newEnemy.x = math.random( display.contentWidth - 120 )
    newEnemy.y = -60
    newEnemy:setLinearVelocity( math.random( -20,20 ), math.random( 150,400 ) )

    newEnemy:applyTorque( math.random( -6,6 ) )
end


local function fireBullet()
 
    audio.play(shot)
    local newBullet = display.newImageRect( mainGroup, "bullet.png", 14, 40 )
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

local function gameLoop()

    --create new enemy
    createEnemy()

    -- Remove asteroids which have drifted off screen
    for i = #enemyTable, 1, -1 do
        local thisEnemy = enemyTable[i]
 
        if ( thisEnemy.x < -100 or
             thisEnemy.x > display.contentWidth + 100 or
             thisEnemy.y < -100 or
             thisEnemy.y > display.contentHeight - 50)
        then
            display.remove( thisEnemy )
            table.remove( enemyTable, i )
        end
    end
end


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

local function endGame()
    composer.setVariable( "finalScore", score )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "bullet" and obj2.myName == "enemy" ) or
             ( obj1.myName == "enemy" and obj2.myName == "bullet" ) )
        then
            audio.play(explosion)
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
                    audio.play(thirdDeathSound)
                    timer.performWithDelay( 2000, endGame )
                else
                    audio.play(death)
                    player.alpha = 0
                    timer.performWithDelay( 1000, restorePlayer )
                end
            end
        end
    end
end

local function pauseFunction(event)

    if event.phase == "ended" then
        isPlay = not isPlay
        if isPlay then
            physics:start()
            player:addEventListener( "tap", fireBullet )
            player:addEventListener( "touch", dragPlayer )
            gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 0 )
            --resume.destroy --funzione che canella la scritta, da implementare
        else
            physics:pause()
            player:removeEventListener( "tap", fireBullet )
            player:removeEventListener( "touch", dragPlayer )
            timer.cancel(gameLoopTimer)
            resume = display.newText("Paused, tap pause button to resume", display.contentCenterX, display.contentCenterY, "KGDoYouLoveMe.ttf", 30 )
            resume:setFillColor(0,0,0)
        end
    end
end




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()  -- Temporarily pause the physics engine

	-- Set up display groups
    backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
 
    mainGroup = display.newGroup()  -- Display group for the player, asteroids, lasers, etc.
    sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
 
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group
	
	-- Load the background
    --local background = display.newImageRect( backGroup, "gamebg.png", 800, 1400 )
    --background.x = display.contentCenterX
    --background.y = display.contentCenterY

    -- Set Variables
    _W = display.contentWidth -- Get the width of the screen
    _H = display.contentHeight -- Get the height of the screen
    scrollSpeed = 2 -- Set Scroll Speed of background
	
    -- Add First Background
    bg1 = display.newImageRect(backGroup, "gamebg.png", 800, 1400)
    bg1.x = _W*0.5; bg1.y = _H/2
	
    -- Add Second Background
    bg2 = display.newImageRect(backGroup, "gamebg.png", 800, 1400)
    bg2.x = _W*0.5; bg2.y = bg1.y+1400
	
    -- Add Third Background
    bg3 = display.newImageRect(backGroup, "gamebg.png", 800, 1400)
    bg3.x = _W*0.5; bg3.y = bg2.y+1400
    
    -- create a five point high wall the width of the screen position at top:
    local wallWidth = 300
    local fullw   = display.contentWidth
    local fullh   = display.contentHeight
    local centerX = display.contentCenterX
    local centerY = display.contentCenterY

    local leftWall = display.newRect( -60, centerY, wallWidth, fullh )
    local rightWall = display.newRect( fullw+60, centerY, wallWidth, fullh )
    --local topWall = display.newRect( centerX, 0-wallWidth/2, fullw, wallWidth )
    local bottomWall = display.newRect( centerX, fullh+wallWidth/2, fullw, wallWidth )

    local redCollisionFilter = { groupIndex = -2 }

    physics.addBody( leftWall, "static", {bounce = 0.0, friction = 2} ) -- filter = {maskBits = 2, categoryBits = 2}
    physics.addBody( rightWall, "static", {bounce = 0.0, friction = 2} ) 
    --physics.addBody( topWall, "static", {bounce = 0.0, friction = 2} )
    physics.addBody( bottomWall, "static", { isSensor=true }, {bounce = 0.0, friction = 2} )

    player = display.newImageRect( mainGroup, "spaceship.png", 128, 128 )
    player.x = display.contentCenterX
    player.y = display.contentHeight - 100
    physics.addBody( player, "dynamic", { radius=60, isSensor=false} )
    player.myName = "player"
 
    -- Display lives and score
    livesText = display.newText( uiGroup, "Lives: " .. lives, 220, 80, "KGDoYouLoveMe.ttf", 36 )
    livesText:setFillColor(0,0,0)
	scoreText = display.newText( uiGroup, "Score: " .. score, 500, 80, "KGDoYouLoveMe.ttf", 36 )
    scoreText:setFillColor(0,0,0)
    
    
	player:addEventListener( "tap", fireBullet )
    player:addEventListener( "touch", dragPlayer )

    button = display.newImageRect(mainGroup, "pause.png", 60, 60)
    button.x = display.contentCenterX
    button.y = 80
    button.myName = "button"

    button:addEventListener( "touch", pauseFunction )

    thirdDeathSound=audio.loadSound("audio/death3.wav")
    death=audio.loadSound("audio/death.wav")
    shot=audio.loadSound("audio/shot.wav")
    explosion=audio.loadSound("audio/explosion.wav")

    
end

local function move(event)
	-- move backgrounds to the left by scrollSpeed, default is 2
	bg1.y = bg1.y + scrollSpeed
	bg2.y = bg2.y + scrollSpeed
	bg3.y = bg3.y + scrollSpeed
	
	-- Set up listeners so when backgrounds hits a certain point off the screen,
	-- move the background to the right off screen
	if (bg1.y + bg1.contentWidth) > 2800 then
	bg1:translate( 0, -2800 )
	end
	if (bg2.y + bg2.contentWidth) > 2800 then
	bg2:translate( 0, -2800 )
	end
	if (bg3.y + bg3.contentWidth) > 2800 then
	bg3:translate( 0, -2800 )
	end
end

-- Create a runtime event to move backgrounds
Runtime:addEventListener( "enterFrame", move )

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
        Runtime:addEventListener( "collision", onCollision )
        gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 0 )

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        timer.cancel( gameLoopTimer )
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener( "collision", onCollision )
        physics.pause()
        composer.removeScene( "game" )
    end
end



-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene