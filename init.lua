local modname = core.get_current_modname()
local src_path = core.get_modpath(modname) .. "/src"
dofile(src_path .. "/api.lua")

local version = "1.0.0"

core.log("action", "[FeedHook] Mod initialised, running version " .. version)


--[[Copyright (C) 2025
Smnoe01 (Atlante) (discord: smnoe01)
Attribution-NonCommercial-ShareAlike 4.0 International

Creative Commons Corporation (“Creative Commons”) is not a law firm and does not provide legal services or legal advice.
Distribution of Creative Commons public licenses does not create a lawyer-client or other relationship.
Creative Commons makes its licenses and related information available on an “as-is” basis.
Creative Commons gives no warranties regarding its licenses, any material licensed under their terms and conditions, or any related information.
Creative Commons disclaims all liability for damages resulting from their use to the fullest extent possible.
Using Creative Commons Public Licenses]]