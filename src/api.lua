--[[Copyright (C) 2025
Smnoe01 (Atlante) (discord: smnoe01)
Attribution-NonCommercial-ShareAlike 4.0 International

Creative Commons Corporation (“Creative Commons”) is not a law firm and does not provide legal services or legal advice.
Distribution of Creative Commons public licenses does not create a lawyer-client or other relationship.
Creative Commons makes its licenses and related information available on an “as-is” basis.
Creative Commons gives no warranties regarding its licenses, any material licensed under their terms and conditions, or any related information.
Creative Commons disclaims all liability for damages resulting from their use to the fullest extent possible.
Using Creative Commons Public Licenses]]

local modname = core.get_current_modname()
local S = core.get_translator(modname)
local http = core.request_http_api()

local system_config = {
    discord_webhook_urls = {
        server_suggestions = core.settings:get("server_suggestion_webhook_url") or "",

        --[[On désactive car pas nécessaire actuellement]]
        --player_reports = core.settings:get("webhook_url_reports") or "",
        --bug_reports = core.settings:get("webhook_url_bugs") or "",
    },
    message_validation_rules = {
        maximum_characters = tonumber(core.settings:get("maximum_characters")) or 500,
        minimum_characters = tonumber(core.settings:get("maximum_characters")) or 25,
        cooldown_duration_seconds = tonumber(core.settings:get("cooldown_duration_seconds")) or 300,
    }
}

local last_suggestion_time = {}

local function sanitize_message(message)
    if not message then return "" end

    -- On évite les message de ce genre
    message = message:gsub("@everyone")
    message = message:gsub("@here")

    return message
end

local function send_webhook(suggester, suggestion)
    local clean_suggester_name = sanitize_message(suggester)
    local clean_suggestion_message = sanitize_message(suggestion)

    local embed = {
        title = "[In-Game Suggestion]",
        -- Couleur hexadécimal convertie en décimal pour discord
        color = 0,
        fields = {
            {name = "Player: ", value = clean_suggester_name, inline = true},
            {name = "Suggestion: ", value = clean_suggestion_message, inline = false},
        },
        footer = {text = "In-Game Suggestion Logger"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local json = core.write_json({embeds = {embed}})

    http.fetch({
        url = system_config.discord_webhook_urls.server_suggestions,
        method = "POST",
        extra_headers = {"Content-Type: application/json"},
        data = json,
    },

    function(res)
        if not res.succeeded then
            core.log("error", "[Feedhook-Webhook] Sending failed: (" .. (res.code or "unknown") .. ")")
        end
    end)
end

core.register_chatcommand("suggestion", {
    params = S("<message>"),
    description = S("Send a suggestion to the administrative team."),
    privs = {shout = true},
    func = function(name, param)
        if not param or param:trim() == "" then
            return false, S("Usage: /suggestion <message>")
        end

        if not http or system_config.discord_webhook_urls.server_suggestions == "" then
            return false, S("The suggestion system is currently unavailable. please contact the administrative team.")
        end

        -- Validation min/max de la longeur du message avec message_validation_rules
        if #param < system_config.message_validation_rules.minimum_characters then
            return false, S("Message too") .. S(" short ") .. "(" .. S("minimum") .. ": " .. system_config.message_validation_rules.minimum_characters .. S(" caracters") .. ")"
        elseif #param > system_config.message_validation_rules.maximum_characters then
            return false, S("Message too") .. S(" long ") .. "(" .. S("maximum") .. ": " .. system_config.message_validation_rules.maximum_characters .. S(" caracters") .. ")"
        end

        local current_time = os.time()
        local last_time = last_suggestion_time[name] or 0

        if current_time - last_time < system_config.message_validation_rules.cooldown_duration_seconds then
            local remaining = math.ceil(system_config.message_validation_rules.cooldown_duration_seconds - (current_time - last_time))
            return false, S("Please wait ") .. remaining .. S(" seconds before using /suggestion again.")
        end

        last_suggestion_time[name] = current_time

        send_webhook(name, param)

        return true, S("Your suggestion has been sent to the administrative team.")
    end,
})