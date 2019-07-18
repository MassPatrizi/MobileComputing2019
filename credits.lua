
local composer = require( "composer" )

local scene = composer.newScene()

local menuSound = audio.loadSound("Videogame_Menu_Button_Clicking_Sounds.wav")
audio.setVolume(2, {channel=3})

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoMenu()
    audio.play(menuSound, {channel = 3})
    composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
    
    local background = display.newImageRect( sceneGroup, "menubg2.jpg", 800, 1400 )
    background.x = display.contentCenterX
	background.y = display.contentCenterY

    local y = 300;

    local title = display.newText( sceneGroup, "CREDITS", display.contentCenterX, y - 100, "Riffic.ttf", 60 )
    title:setFillColor( 0.75, 0.78, 1 )

    local credits01 = display.newText( sceneGroup, "DEVELOPED BY", display.contentCenterX, y , "Riffic.ttf", 22 )
    credits01:setFillColor(0.75, 0.78, 1 )

	local credits1 = display.newText( sceneGroup, "Cristian Tinaburri", display.contentCenterX, y + 60, "Riffic.ttf", 35 )
	credits1:setFillColor( 255, 255, 255 )

    local credits2 = display.newText( sceneGroup, "Giorgia Nesci", display.contentCenterX, y + 120, "Riffic.ttf", 35 )
    credits2:setFillColor( 255, 255, 255 )
	
    local credits3 = display.newText( sceneGroup, "Massimiliano Patrizi", display.contentCenterX, y + 180, "Riffic.ttf", 35 )
	credits3:setFillColor( 255, 255, 255 )

	local musicCredit = display.newText( sceneGroup, "MUSIC", display.contentCenterX, y + 250, "Riffic.ttf", 22 )
	musicCredit:setFillColor( 0.75, 0.78, 1 )
	
	local music1 = display.newText( sceneGroup, "8 Bit Space Groove! by HeatleyBros", display.contentCenterX, y + 300, "Riffic.ttf", 22 )
	music1:setFillColor( 255, 255, 255 )

	local music2 = display.newText( sceneGroup, "[8-Bit Speedcore] antiPLUR - Speed of Link", display.contentCenterX, y + 350, "Riffic.ttf", 22 )
	music2:setFillColor( 255, 255, 255 )

	local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, y + 500, "Riffic.ttf", 44 )
    menuButton:setFillColor( 0.75, 0.78, 1 )
	menuButton:addEventListener( "tap", gotoMenu )
	
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
		composer.removeScene( "highscores" )

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