local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local webhook = "" --Add webhook right here
-- Test Command for testing the log system
    RegisterCommand("combat", function(source, args, rawcmd)
        TriggerClientEvent("remd-combat-log:show", source)
    end)
   --[[ RegisterCommand("testlog", function(source, args, rawcmd)
        local reason = "Test"
        writelog(source,reason)
    end)]]--
-- End of test commands
function writelog(source,reason)
    local crds = GetEntityCoords(GetPlayerPed(source))
    local id = source
    local identifier = ""
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local name = ""
    if Config.UseSteam then
        identifier = GetPlayerIdentifier(source, 0)
    else
        identifier = GetPlayerIdentifier(source, 1)
    end
    if Config.Name then
        if Config.LastName then
            name = (Character.firstname or "no name") .. ' ' .. (Character.lastname or "noname") --player char name
        else
            name = (Character.firstname or "no name")
        end
    else
        name = "Player Left Game"
    end
    TriggerClientEvent("remd-combat-log", -1, id, crds, identifier, reason, name)
    if Config.LogSystem then
        SendLog(id, crds, identifier, reason, name)
    end
end
AddEventHandler("playerDropped", function(reason)
    local _src = source
    writelog(_src,reason)
end)
function SendLog(id, crds, identifier, reason, name)
    local name = GetPlayerName(id)
    local _source = id
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local icname = (Character.firstname or "no name") .. ' ' .. (Character.lastname or "noname") --player char name
    local date = os.date('*t')

    if date.month < 10 then date.month = '0' .. tostring(date.month) end
    if date.day < 10 then date.day = '0' .. tostring(date.day) end
    if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
    if date.min < 10 then date.min = '0' .. tostring(date.min) end
    if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
    local date = (''..date.day .. '.' .. date.month .. '.' .. date.year .. ' - ' .. date.hour .. ':' .. date.min .. ':' .. date.sec..'')
    local embeds = {
        {
            ["title"] = "Player Disconnected",
            ["type"]="rich",
            ["color"] = 4777493,
            ["fields"] = {
                {
                    ["name"] = "Identifier",
                    ["value"] = identifier,
                    ["inline"] = true,
                },{
                    ["name"] = "Nickname",
                    ["value"] = name,
                    ["inline"] = true,
                },{
                    ["name"] = "Player's ID",
                    ["value"] = id,
                    ["inline"] = true,
                },{
                    ["name"] = "Cordinates",
                    ["value"] = "X: "..crds.x..", Y: "..crds.y..", Z: "..crds.z,
                    ["inline"] = true,
                },{
                    ["name"] = "Reason",
                    ["value"] = reason,
                    ["inline"] = true,
                },{
                    ["name"] = "Name",
                    ["value"] = icname,
                    ["inline"] = true,
                },
            },
            ["footer"]=  {
                ["icon_url"] = "https://i.imgur.com/KVh9oxB.png",
                ["text"]= "Sent: " ..date.."",
            },
        }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ username = Config.LogBotName,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end
