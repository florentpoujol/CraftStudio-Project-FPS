
function Behavior:Awake()

    -- server name
    local nameInputGO = GameObject.Get( "Name.Input" )
    nameInputGO.input.OnValidate = function( input )
        Server.localData.name = input.gameObject.textRenderer.text
        self:SaveServerData()        
    end
    nameInputGO.input.OnFocus = function( input )
        if input.isFocused then
            input.gameObject.child.modelRenderer.opacity = 0.5
        else
            Server.localData.name = input.gameObject.textRenderer.text
            self:SaveServerData()
            input.gameObject.child.modelRenderer.opacity = 0.2        
        end
    end
        
    nameInputGO.textRenderer.text = Server.localData.name
    
    -- max players
    local playerInputGO = GameObject.Get( "Max Players.Input" )
    playerInputGO.input.OnValidate = function( input )
        Server.localData.maxPlayerCount = tonumber( input.gameObject.textRenderer.text )
        self:SaveServerData()
    end
    playerInputGO.input.OnFocus = function( input )
        if input.isFocused then
            input.gameObject.child.modelRenderer.opacity = 0.5
        else
            Server.localData.maxPlayerCount = tonumber( input.gameObject.textRenderer.text )
            self:SaveServerData()
            input.gameObject.child.modelRenderer.opacity = 0.2        
        end
    end
    
    playerInputGO.textRenderer.text = Server.localData.maxPlayerCount
    
    
    -- private (private servers don't shows up in the server browser)
    local privateToggle = GameObject.Get( "Private.Toggle" )
    privateToggle:AddComponent( "GUI.Toggle", {
        isChecked = Server.localData.isPrivate, -- false = no, true = yes
        text = "Is Private",
        checkedMark =  "Yes  :text",
        uncheckedMark = "No  :text",
    } )
    privateToggle.toggle.OnUpdate = function( toggle )
        Server.localData.isPrivate = toggle.isChecked
        self:SaveServerData()
    end
    
    -- initial scene
    local levelInputGO = GameObject.Get( "Initial Level.Input" )
    levelInputGO.input.OnValidate = function( input )
        Server.localData.initialScene = input.gameObject.textRenderer.text
        self:SaveServerData()        
    end
    levelInputGO.input.OnFocus = function( input )
        if input.isFocused then
            input.gameObject.child.modelRenderer.opacity = 0.5
        else
            Server.localData.initialScene = input.gameObject.textRenderer.text
            self:SaveServerData()
            input.gameObject.child.modelRenderer.opacity = 0.2        
        end
    end
        
    levelInputGO.textRenderer.text = Server.localData.initialScene
    
    
    -- load saved data
    Daneel.Storage.Load( "PFPS_ServerData", function( value, error ) 
        if value == nil then
            msg( "ERROR : Unable to load server data." )
            -- always happens the first time
            return
        end
        
        --msg( "Loaded server data" )
        if value.name == nil then
            value.name = Server.localData.name
        end
        if value.maxPlayerCount == nil then
            value.maxPlayerCount = Server.localData.maxPlayerCount
        end
        if value.isPrivate == nil then
            value.isPrivate = Server.localData.isPrivate
        end
        if value.initialScene == nil then
            value.initialScene = Server.localData.initialScene
        end
        
        Server.localData = value
        nameInputGO.textRenderer.text = value.name
        playerInputGO.textRenderer.text = value.maxPlayerCount
        privateToggle.toggle:Check( value.isPrivate )
        levelInputGO.textRenderer.text = value.initialScene
    end )
    
    
    -- start/stop button
    local buttonGO = GameObject.Get( "Start-Stop Button" )
    local startText = "Start server"
    local stopText = "Stop server"
    
    buttonGO.OnClick = function()
        self:SaveServerData()
        
        if LocalServer then
            Server.Stop( function( server, data )
                if data and data.deleteFromServerBrowser then
                    msg( "Successfully removed the server from the server browser" )
                end
            end )
            buttonGO.textRenderer.text = startText
        else
            Server.Start( function( server )
                if server.id ~= nil then
                    msg( "Successfully posted on the server browser with id "..server.id.." and IP "..server.ip )
                else
                    msg( "Unable to contact the server browser" )
                end
            end )
            buttonGO.textRenderer.text = stopText
        end
    end
    
    if LocalServer then
        buttonGO.textRenderer.text = stopText
    else
        buttonGO.textRenderer.text = startText
    end
end


function Behavior:Update()
    if CS.Input.WasButtonJustPressed( "Escape" ) then
        Scene.Load( "Menus/Main Menu" )
    end
end


function Behavior:SaveServerData()
    Daneel.Storage.Save( "PFPS_ServerData", Server.localData, function( error )
        if error ~= nil then
            msg( "Unable to save server data : can't write data" )
        else
            msg( "Server data saved successfully." )
        end
    end )
end
