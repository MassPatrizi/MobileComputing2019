
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
	


local title = display.newImageRect( sceneGroup, "title.png", 400, 200)
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
