
local composer = require( "composer" )

local scene = composer.newScene()
local menuMusic=audio.loadSound("menuMusic.wav")
local playSound=audio.loadSound("click_sfx2.wav")
audio.setVolume(2, {channel=2})
local highScoresSound=audio.loadSound("Videogame_Menu_Button_Clicking_Sounds.wav")
audio.setVolume(2, {channel=2})
local gameMusic = audio.loadSound("gameMusic.wav")
audio.setVolume(0.1, {channel = 3})


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function gotoGame()
	audio.play(playSound, {channel = 2})
	audio.stop(1)
	audio.play(gameMusic, {channel = 3, loops = -1})
	composer.gotoScene( "game" , { time=800, effect="crossFade"})
end
 
local function gotoHowToPlay()
	audio.play(playSound, {channel = 2})
    composer.gotoScene( "howtoplay" , { time=800, effect="crossFade" } )
end

local function gotoHighScores()
	audio.play(playSound, {channel = 2})
    composer.gotoScene( "highscores" , { time=800, effect="crossFade" } )
end

local function gotoCredits()
	audio.play(playSound, {channel = 2})
    composer.gotoScene( "credits" , { time=800, effect="crossFade" } )
end

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "menubg2.jpg", 800, 1400 )
    background.x = display.contentCenterX
	background.y = display.contentCenterY
	
--[[
-- Set Variables
_W = display.contentWidth -- Get the width of the screen
_H = display.contentHeight -- Get the height of the screen
scrollSpeed = 2 -- Set Scroll Speed of background
	
-- Add First Background
bg1 = display.newImageRect(sceneGroup, "menubg.jpg", 800, 1400)
bg1.x = _W*0.5; bg1.y = _H/2
	
-- Add Second Background
bg2 = display.newImageRect(sceneGroup, "menubg.jpg", 800, 1400)
bg2.x = _W*0.5; bg2.y = bg1.y+1400
	
-- Add Third Background
bg3 = display.newImageRect(sceneGroup, "menubg.jpg", 800, 1400)
bg3.x = _W*0.5; bg3.y = bg2.y+1400
]]--

local title = display.newImageRect( sceneGroup, "title.png", 400, 200)

--local title = display.newText( sceneGroup, "ENDLESS\n STARS", display.contentCenterX, 700, "Riffic.ttf", 70 )
    title.x = display.contentCenterX
	title.y = 200


local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 500, "Riffic.ttf", 44 )
playButton:setFillColor( 255, 255, 255 )

local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 600, "Riffic.ttf", 44 )
highScoresButton:setFillColor( 255, 255, 255 )

local howToPlayButton = display.newText( sceneGroup, "How to Play", display.contentCenterX, 700, "Riffic.ttf", 44 )
howToPlayButton:setFillColor( 255, 255, 255 )

local creditsButton = display.newText( sceneGroup, "Credits", display.contentCenterX, 800, "Riffic.ttf", 44 )
creditsButton:setFillColor( 255, 255, 255 )
	
playButton:addEventListener( "tap", gotoGame)
howToPlayButton:addEventListener( "tap", gotoHowToPlay)
highScoresButton:addEventListener( "tap", gotoHighScores)
creditsButton:addEventListener( "tap", gotoCredits)
audio.play(menuMusic, {channel = 1, loops = -1})
audio.setVolume(0.1, {channel = 1})

	
end

--[[
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
]]--

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

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


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 



return scene
