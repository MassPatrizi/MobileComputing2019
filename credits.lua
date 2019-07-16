
local composer = require( "composer" )

local scene = composer.newScene()

local menuSound = audio.loadSound("audio/Videogame_Menu_Button_Clicking_Sounds.wav")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoMenu()
    audio.play(menuSound)
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

    local y = 420;

    local title = display.newText( sceneGroup, "CREDITS", display.contentCenterX, y - 220, "Riffic.ttf", 60 )
    title:setFillColor( 0.75, 0.78, 1 )

    local credits01 = display.newText( sceneGroup, "DEVELOPED BY", display.contentCenterX, y , "Riffic.ttf", 22 )
    credits01:setFillColor(0.75, 0.78, 1 )

	local credits1 = display.newText( sceneGroup, "Cristian Tinaburri", display.contentCenterX, y + 60, "Riffic.ttf", 35 )
	credits1:setFillColor( 0.75, 0.78, 1 )
	
	local credits1A = display.newText( sceneGroup, "[Lead Dev]", display.contentCenterX, y + 90, "Riffic.ttf", 22 )
	credits1A:setFillColor( 0.75, 0.78, 1 )

    local credits2 = display.newText( sceneGroup, "Giorgia Nesci", display.contentCenterX, y + 160, "Riffic.ttf", 35 )
    credits2:setFillColor( 0.75, 0.78, 1 )

	local credits2A = display.newText( sceneGroup, "[Audio - Coder]", display.contentCenterX, y + 190, "Riffic.ttf", 22 )
	credits2A:setFillColor( 0.75, 0.78, 1 )
	
    local credits3 = display.newText( sceneGroup, "Massimiliano Patrizi", display.contentCenterX, y + 260, "Riffic.ttf", 35 )
	credits3:setFillColor( 0.75, 0.78, 1 )
	
	local credits3A = display.newText( sceneGroup, "[Designer - Coder]", display.contentCenterX, y + 290, "Riffic.ttf", 22 )
    credits3A:setFillColor( 0.75, 0.78, 1 )

	local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, y + 380, "Riffic.ttf", 44 )
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