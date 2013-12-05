--[[PublicProperties
areaWidth string ""
wordWrap boolean False
newLine string "\n"
lineHeight string "1"
verticalAlignment string "top"
font string ""
text string "Text\nArea"
alignment string ""
opacity number 1
/PublicProperties]]
-- TextArea.lua
-- Scripted behavior for GUI.TextArea component.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT license.



function Behavior:Awake()
    if self.gameObject.textArea == nil then
        local params = {
            wordWrap = self.wordWrap,
            opacity = self.opacity,
            text = self.text,
        }
        local props = {"areaWidth", "newLine", "lineHeight", "verticalAlignment", "font", "alignment"}
        for i, prop in ipairs( props ) do
            if self[ prop ]:trim() ~= "" then
                params[ prop ] = self[ prop ]
            end
        end

        GUI.TextArea.New( self.gameObject, params )
    end
end
