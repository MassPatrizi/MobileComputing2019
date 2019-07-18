system.activate( "multitouch" )
local composer = require( "composer" )

local scene = composer.newScene()

local thirdDeathSound
local death
local shot
local explosion
local healthup
local menuMusic = audio.loadSound("menuMusic.wav")
local gameMusic = audio.loadSound("gameMusic.wav")
audio.reserveChannels(3)
audio.setVolume(0.1, {channel = 1})
audio.setVolume(2, {channel = 2})
audio.setVolume(0.1, {channel = 3})


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

    newEnemy.x = math.random( display.contentWidth - 120)
    newEnemy.y = -60
    newEnemy:setLinearVelocity( math.random( -20,20 ), math.random( 150,400 ) )

    if(score>2000) then
        newEnemy:setLinearVelocity( math.random( -20,20 ), math.random( 250,450 ) )
    elseif(score>10000) then
        newEnemy:setLinearVelocity( math.random( -20,20 ), math.random( 350,600 ) )
    end

    newEnemy:applyTorque( math.random( -6,6 ) )
end

local function createBonusEnemy()
    -- local redCollisionFilter = { groupIndex = -2 }
    local newEnemy = display.newImageRect( mainGroup, "sun.png", 90, 90 )
    table.insert( enemyTable, newEnemy )
    physics.addBody( newEnemy, "dynamic", { radius=40, bounce=0} ) -- , filter = {maskBits = 2, categoryBits = 2}
    newEnemy.myName = "bonusEnemy"

    newEnemy.x = math.random( display.contentWidth - 120 )
    newEnemy.y = -60
    newEnemy:setLinearVelocity( math.random( -20,20 ), math.random( 400,600 ) )

    newEnemy:applyTorque( math.random( -6,6 ) )
end

local function createHealthUp()
    -- local redCollisionFilter = { groupIndex = -2 }
    local healthUp = display.newImageRect( mainGroup, "planetHealth.png", 100, 100 )
    table.insert( enemyTable, healthUp )
    physics.addBody( healthUp, "dynamic", { radius=40, bounce=0} ) -- , filter = {maskBits = 2, categoryBits = 2}
    healthUp.myName = "healthUp"

    healthUp.x = math.random( display.contentWidth - 120 )
    healthUp.y = -60
    healthUp:setLinearVelocity( math.random( -20,20 ), math.random( 300,500 ) )

    healthUp:applyTorque( math.random( -3,3 ) )
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

local function bonusGameLoop()

    --create new enemy
    createBonusEnemy()

    -- Remove asteroids which have drifted off screen
    for i = #enemyTable, 1 , -1 do
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

local function healthGameLoop()

    --create new enemy
    createHealthUp()

    -- Remove asteroids which have drifted off screen
    for i = #enemyTable, 1 , -1 do
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

        elseif( (obj1.myName == "bullet" and obj2.myName == "bonusEnemy") or
                (obj1.myName == "bonusEnemy" and obj2.myName == "bullet"))
                then 
                    audio.play(explosion)
                    --remove both the bullet and enemy
                    display.remove(obj1)
                    display.remove(obj2)

                    for i = #enemyTable, 1, -1 do
                        if ( enemyTable[i] == obj1 or enemyTable[i] == obj2 ) then
                            table.remove( enemyTable, i )
                            break
                        end
                    end

                     -- Increase score
            score = score + 800
            scoreText.text = "Score: " .. score

        elseif((obj1.myName == "healthUp" and obj2.myName == "player") or
                (obj1.myName == "player" and obj2.myName == "healthUp"))
                then
                    audio.play(healthup, {channel = 2})
                    lives = lives + 1
                    livesText.text = "Lives: " .. lives

                    if(obj1.myName == "healthUp")
                        then display.remove(obj1)
                        else
                         display.remove(obj2)
                    end

                    for i = #enemyTable, 1, -1 do
                        if ( enemyTable[i] == obj1 or enemyTable[i] == obj2 ) then
                            table.remove( enemyTable, i )
                            break
                        end
                    end


        elseif  ( ( obj1.myName == "player" and obj2.myName == "enemy" ) or
            ( obj1.myName == "enemy" and obj2.myName == "player" ) or 
            ( obj1.myName == "player" and obj2.myName == "bonusEnemy" ) or
            ( obj1.myName == "bonusEnemy" and obj2.myName == "player" ) )   
            then
                if ( died == false ) then
                    died = true
                

                     -- Update lives
                     lives = lives - 3
                     livesText.text = "Lives: " .. lives

                if ( lives == 0 ) then
                    display.remove( player )
                    audio.play(thirdDeathSound, {channel = 2})
                    audio.fadeOut({channel = 3, time = 5000})
                    audio.play(menuMusic, {channel = 1, fadein = 5000})
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

local function goToMenu()
    composer.gotoScene("menu", {time = 800, effect="crossFade"})
    display.remove(resume) --rimuove la scritta di pausa
    display.remove(resume2)
    display.remove(mainMenu)
    audio.fadeOut({channel = 3, time = 2000})
    audio.play(menuMusic, {channel = 1, fadein = 5000})
end

local function pauseFunction(event)

    if event.phase == "ended" then
        isPlay = not isPlay
        if isPlay then
            physics:start()
            --bg1:addEventListener( "tap", fireBullet )
            --bg2:addEventListener( "tap", fireBullet )
            --bg3:addEventListener( "tap", fireBullet )
            player:addEventListener( "tap", fireBullet )
            player:addEventListener( "touch", dragPlayer )
            gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 ) --ripristina lo spawn dei nemici
            bonusGameLoopTimer = timer.performWithDelay( 15000, bonusGameLoop, 0)
            healthGameLoopTimer = timer.performWithDelay( 20000, healthGameLoop, 0)
            display.remove(resume) --rimuove la scritta di pausa
            display.remove(resume2)
            display.remove(mainMenu)
            bg1.fill.effect = ""
            bg2.fill.effect = ""
            bg3.fill.effect = ""
            scrollSpeed = 2
        else
            physics:pause()
            --bg1:removeEventListener( "tap", fireBullet ) --impedisce al giocatore di poter sparare
            --bg2:removeEventListener( "tap", fireBullet )
            --bg3:removeEventListener( "tap", fireBullet )
            player:removeEventListener( "tap", fireBullet )
            player:removeEventListener( "touch", dragPlayer ) --impedisce al giocatore di muovere la navicella
            timer.cancel(gameLoopTimer) --annulla la funzione che genera nemici.
            timer.cancel(bonusGameLoopTimer)
            timer.cancel(healthGameLoopTimer)
            resume = display.newText("Game paused", display.contentCenterX, display.contentCenterY-50, "Riffic.ttf", 50 )
            resume:setFillColor(255,255,0)
            resume2 = display.newText("tap on lives/score to resume", display.contentCenterX, display.contentCenterY, "Riffic.ttf", 30 )
            resume2:setFillColor(255,255,0)
            mainMenu = display.newText("Main Menu", display.contentCenterX, display.contentCenterY+300, "Riffic.ttf", 50)
            mainMenu:setFillColor(255,255,0)
            mainMenu:addEventListener("tap", goToMenu)
            bg1.fill.effect = "filter.grayscale"
            bg2.fill.effect = "filter.grayscale"
            bg3.fill.effect = "filter.grayscale"
            scrollSpeed = 0.2
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

    local leftWall = display.newRect( -120, centerY, wallWidth, fullh )
    local rightWall = display.newRect( fullw+120, centerY, wallWidth, fullh )
    --local topWall = display.newRect( centerX, 0-wallWidth/2, fullw, wallWidth )
    local bottomWall = display.newRect( centerX, fullh+wallWidth/2+120, fullw, wallWidth )

    local redCollisionFilter = { groupIndex = -2 }

    physics.addBody( leftWall, "static", {bounce = 0.0, friction = 2} ) -- filter = {maskBits = 2, categoryBits = 2}
    physics.addBody( rightWall, "static", {bounce = 0.0, friction = 2} ) 
    --physics.addBody( topWall, "static", {bounce = 0.0, friction = 2} )
    physics.addBody( bottomWall, "static", { isSensor=true }, {bounce = 0.0, friction = 2} )

    player = display.newImageRect( mainGroup, "rocketfixed.png", 119, 180 )
    player.x = display.contentCenterX
    player.y = display.contentHeight - 100
    physics.addBody( player, "dynamic", { density = 100, radius=60, isSensor=false} )
    player.isFixedRotation = true
    player.myName = "player"
 
    -- Display lives and score
    livesText = display.newText( uiGroup, "Lives: " .. lives, display.contentCenterX, 80, "Riffic.ttf", 36 )
    livesText:setFillColor(255,255,0)
	scoreText = display.newText( uiGroup, "Score: " .. score, display.contentCenterX, 116, "Riffic.ttf", 36 )
    scoreText:setFillColor(255,255,0)
    
    
    --bg1:addEventListener( "tap", fireBullet )
    --bg2:addEventListener( "tap", fireBullet )
    --bg3:addEventListener( "tap", fireBullet )
    player:addEventListener( "tap", fireBullet )
    player:addEventListener( "touch", dragPlayer )

    livesText:addEventListener( "touch", pauseFunction )
    scoreText:addEventListener( "touch", pauseFunction )

    thirdDeathSound=audio.loadSound("death3.wav")
    death=audio.loadSound("death.wav")
    shot=audio.loadSound("shot.wav")
    explosion=audio.loadSound("explosion.wav")
    healthup=audio.loadSound("healthup.wav")


    
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
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
        bonusGameLoopTimer = timer.performWithDelay( 15000, bonusGameLoop, 0)
        healthGameLoopTimer = timer.performWithDelay( 20000, healthGameLoop, 0)

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        timer.cancel( gameLoopTimer )
        timer.cancel(bonusGameLoopTimer)
        timer.cancel(healthGameLoopTimer)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener( "collision", onCollision )
        Runtime:removeEventListener("enterFrame", move)
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
