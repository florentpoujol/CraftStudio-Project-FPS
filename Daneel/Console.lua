
Console = {}
if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end  
CS.DaneelModules[ "Console" ] = Console


function Console.Load()
    GUI.Console = {}
    GUI.Console.__index = GUI.Console
    
    Daneel.Config.componentObjects.Console = GUI.Console
    table.insert( Daneel.Config.componentTypes, "Console" )
    Daneel.Config.objects.Console = GUI.Console   
    
    function GUI.Console.New( gameObject, params )
        local console = setmetatable( {}, GUI.Console )
        gameObject.console = console
        
        console.textArea = gameObject.textArea
        if console.textArea == nil then
            console.textArea = GUI.TextArea.New( gameObject, { text = "" } )
        end
        console.height = 10 -- 10 lines
        console.showLineNumber = true
        console.lastLineNumber = 0
        console.filter = nil -- function which gets the line as argument and must return the line or false or nil (in which cases, the line is not added to the console)
        -- this allows to "listen" for commands (or slang) in the lines.
        
        if params ~= nil then
            Component.Set( console, params )
        end
        
        return console
    end

    function GUI.Console.AddLine( console, line )
        if console.filter ~= nil then
            line = console.filter( line )
            if not line then
                return
            end
        end
        --print("-------- add line -----")
        local lines = console.textArea.text:split( console.textArea.newLine )
        --table.print( lines )
        if console.showLineNumber then
            line = "#"..console.lastLineNumber.." "..line
            console.lastLineNumber = console.lastLineNumber + 1
        end
        table.insert( lines, line )
        lines = table.reverse( lines )
        
        local newLines = {}
        for i = 1, console.height do
            if lines[ i ] ~= nil then
                table.insert( newLines, lines[ i ] )
            end
        end
        newLines = table.reverse( newLines )
        
        local text = table.concat( newLines, console.textArea.newLine )
        console.textArea.text = text
    end
end



------------------------------------------------

local consoleGO = nil

function cprint( ... )
    print( ... )
    
    if consoleGO == nil or consoleGO.inner == nil then    
        consoleGO = GameObject.Get( "Console" )
    end
    
    if consoleGO ~= nil then
        if consoleGO.console == nil then
            GUI.Console.New( consoleGO )
        end

        local line = ""
        
        for k, v in pairs ( {...} ) do
            if k == 1 then
                line = tostring(v)
            else
                line = line .. " , " .. tostring(v)
            end
        end
        
        consoleGO.console:AddLine( line )
    end
end


function Behavior:Update()
    -- toggle console
    if CS.Input.WasButtonJustPressed( "Console" ) then
        local zero = Vector3(0)
        local scale = self.gameObject.transform.localScale
        if scale == zero then
            self.gameObject.transform.localScale = self.gameObject.lastScale
        else
            print("hide")
            self.gameObject.lastScale = scale
            self.gameObject.transform.localScale = zero
        end
    end
end


------------------------------------------------


-- notification area
-- provide a standarized way to notify player (give him feedback) of something happening
-- while in-game, this can be done via the tchat instead

Alert = {
    gameObject = nil,
    tweener = nil,
}

function Alert.SetText( text, time )
    if Alert.gameObject == nil or Alert.gameObject.inner == nil then
        Alert.gameObject = GameObject.Get( "Alert" )
    end
    
    cprint( text )
    if Alert.gameObject == nil then
        return
    end
    
    if Alert.tweener ~= nil then
        Alert.tweener:Destroy()
    end
    
    Alert.gameObject.child.textRenderer.text = text
    Alert.gameObject.hud.layer = 2
    
    if time == nil then
        time = 3 -- 3 seconds
    end
    if time > 0 then
        Alert.tweener = Tween.Timer( time, Alert.Hide )
    end
end

function Alert.Hide()
    --cprint("Alert hide")
    if Alert.gameObject == nil or Alert.gameObject.inner == nil then
        Alert.gameObject = GameObject.Get( "Alert" )
    end
    if Alert.gameObject == nil then
        return
    end
    
    Alert.tweener = nil
    Alert.gameObject.hud.layer = -50
end
