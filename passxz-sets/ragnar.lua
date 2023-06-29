------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÕES:VRP
------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------------------------------------------------------------------------------------------------------------
Setagens = {
    ["sets.policia_geral"] = { 
        "Comandante - Policia Militar", 
        "Capitao - Policia Militar",  
        "Tenente - Policia Militar",
        "Sargento - Policia Militar",
        "Cabo - Policia Militar",
        "Soldado - Policia Militar",
        "Recruta - Policia Militar",
        "Comandante - FT", 
        "Capitao - FT",  
        "Tenente - FT",
        "Sargento - FT",
        "Cabo - FT",
        "Soldado - FT",
        "Recruta - FT",
        "Comandante - ROTA", 
        "Capitao - ROTA",  
        "Tenente - ROTA",
        "Sargento - ROTA",
        "Cabo - ROTA",
        "Soldado - ROTA",
        "Recruta - ROTA",
    },
    ["sets.policia_rota"] = { 
        "Capitao - ROTA",  
        "Tenente - ROTA",
        "Sargento - ROTA",
        "Cabo - ROTA",
        "Soldado - ROTA",
        "Recruta - ROTA",
    },
    ["sets.policia_ft"] = { 
        "Capitao - FT",  
        "Tenente - FT",
        "Sargento - FT",
        "Cabo - FT",
        "Soldado - FT",
        "Recruta - FT",
    },
    ["sets.policia_rpm"] = {
        "Capitao - Policia Militar",  
        "Tenente - Policia Militar",
        "Sargento - Policia Militar",
        "Cabo - Policia Militar",
        "Soldado - Policia Militar",
        "Recruta - Policia Militar",
    },
    ["sets.samu"] = { 
        "Diretor - SAMU",
        "Vice Diretor - SAMU",
        "Medico Chefe - SAMU",
        "Medico - SAMU",
        "Paramedico - SAMU",
        "Enfermeiro - SAMU",
    },
    ["sets.pc"] = { 
        "Comissario - PC",
        "Agente 1C - PC",
        "Agente 2C - PC",
        "Agente 3C - PC",

        "Inspetor - DEIC",
        "Perito Criminal - DEIC",
        "Investigador 1C - DEIC",
        "Investigador 2C - DEIC",
    },

    ["sets.pcc"] = { 
        "Gerente - PCC",
        "Vapor - PCC",
    },

    ["sets.cv"] = { 
        "Gerente - CV",
        "Vapor - CV",
    },

    ["sets.fdn"] = { 
        "Gerente - FDN",
        "Vapor - FDN",
    },

    ["sets.ada"] = { 
        "Gerente - ADA",
        "Vapor - ADA",
    },

    ["sets.mc"] = { 
        "Vice Lider - MotoClub",
        "Fornecedor - MotoClub",
    },

    ["sets.mafia"] = { 
        "Vice Lider - Mafia",
        "Fornecedor - Mafia",
    },

    ["sets.culto"] = { 
        "Pastor - Culto",
        "Fiel - Culto",
    },
    
    ["sets.mec"] = { 
        "Mecânico - Gerente",
        "Mecânico - Contratado",
    },
} 
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS:MISC
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Notify(src, text, css, time)
    TriggerClientEvent("pNotify:SendNotification", src, {text = text, type = css, timeout = (time*1000),layout = "centerLeft"})
end
function stringSplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('chatMessageEntered')
AddEventHandler('chatMessageEntered', function(name, color, message)
    local source = source
	
	if message:sub(1, 1) == "/" then
		fullcmd = stringSplit(message, " ")
		cmd = fullcmd[1]
		
        if cmd == "/painel" then
			local source = source
			local user_id = vRP.getUserId({source})
            local liberou = false

            for k,v in pairs(Setagens) do
                if vRP.hasPermission({user_id, k}) then
                    liberou = true
                    vRP.buildMenu({"SetLider", { player = vRP.getUserSource({user_id}) }, function(menu)
                        menu.name = "Painel de Set"
                        menu.css = {header_color="rgba(0,125,255,0.75)"}
        
                        menu["Contratar"] = {function(player, choice)
                            vRP.buildMenu({"Contratar", { player = vRP.getUserSource({user_id}) }, function(contratar)
                                contratar.name = "Contrate"
                                contratar.css = {header_color="rgba(0,125,255,0.75)"}
                
                                local choices = Setagens[k]
                                for k,v in pairs(choices) do
                                    contratar[v] = {function(player, choice)
                                        user_id = vRP.getUserId({player})
                                        vRP.prompt({player, "Qual passaporte você deseja contratar como ".. v .." ?", "", function(player, targetId)
                                            if targetId ~= nil then
                                                local nuser_id = tonumber(targetId)
                                                local nplayer = vRP.getUserSource({nuser_id})
                                                if nplayer ~= nil then
                                                    vRP.request({nplayer, "Você aceita ser contratado como ".. v .." ?", 30, function(nplayer, answer)
                                                        if answer then
                                                            local old_job = vRP.getUserGroupByType({nuser_id, "job"})
                                                            vRP.addUserGroup({nuser_id, v})
                                                            Notify(player, "Você contratou o passaporte <b>".. nuser_id .."</b> como <b>".. v .."</b>.", "success", 8)
                                                            Notify(nplayer, "O passaporte <b>".. user_id .."</b> te contratou como <b>".. v .."</b>.", "warning", 8)
                                                            local setLogs = GetConvar("setLogs", "none")
                                                            PerformHttpRequest(setLogs, function(err, text, headers) end, 'POST', json.encode({content =  "**CONTRATAÇÃO** ```" .. "ID: " .. user_id .. " contratou " .. nuser_id .. "\nGrupo antigo: " .. old_job .. "\nGrupo novo: " .. v .. "\nData: " .. os.date("%H:%M:%S %d/%m/%Y") .. "```"}), { ['Content-Type'] = 'application/json' })                                        
                                                            return
                                                        else
                                                            Notify(player, "O passaporte <b>".. nuser_id .."</b> não aceitou.", "error", 8)
                                                            return 
                                                        end
                                                    end})
                                                else
                                                    Notify(player, "Esse passaporte é inválido.", "error", 8)
                                                    return 
                                                end
                                            else
                                                Notify(player, "Esse passaporte é inválido.", "error", 8)
                                                return 
                                            end
                                        end})
                                    end}
                                end
                
                                vRP.openMenu({source, contratar})
                            end})
                        end}

                        menu["Demitir"] = {function(player, choice)
                            vRP.buildMenu({"Demitir", { player = vRP.getUserSource({user_id}) }, function(demitir)
                                demitir.name = "Demita"
                                demitir.css = {header_color="rgba(0,125,255,0.75)"}

                                local choices = Setagens[k]
                                for k,v in pairs(choices) do
                                    demitir[v] = {function(player, choice)
                                        user_id = vRP.getUserId({player})
                                        vRP.prompt({player, "Qual passaporte você deseja desligar de ".. v .." ?", "", function(player, targetId)
                                            if targetId ~= nil then
                                                local nuser_id = tonumber(targetId)
                                                local nplayer = vRP.getUserSource({nuser_id})
                                                if nplayer ~= nil then
                                                    local old_job = vRP.getUserGroupByType({nuser_id, "job"})
                                                    if old_job == v then
                                                        vRP.removeUserGroup({nuser_id, v})
                                                        Notify(player, "Você desligou o passaporte <b>".. nuser_id .."</b> de <b>".. v .."</b>.", "success", 8)
                                                        Notify(nplayer, "O passaporte <b>".. user_id .."</b> te demitiu.", "warning", 8)
                                                        local setLogs = GetConvar("setLogs", "none")
                                                        PerformHttpRequest(setLogs, function(err, text, headers) end, 'POST', json.encode({content =  "**DEMISSÃO** ```" .. "ID: " .. user_id .. " demitiu " .. nuser_id .. "\nGrupo antigo: " .. old_job .. "\nGrupo novo: " .. v .. "\nData: " .. os.date("%H:%M:%S %d/%m/%Y") .. "```"}), { ['Content-Type'] = 'application/json' })                                        
                                                        return
                                                    else
                                                        Notify(player, "Esse passaporte não é um <b>".. v .."</b>.", "error", 8)
                                                        return 
                                                    end
                                                else
                                                    Notify(player, "Esse passaporte é inválido.", "error", 8)
                                                    return 
                                                end
                                            else
                                                Notify(player, "Esse passaporte é inválido.", "error", 8)
                                                return 
                                            end
                                        end})
                                    end}    
                                end
                                
                                vRP.openMenu({source, demitir})
                            end})
                        end}

                        vRP.openMenu({source, menu})
                    end})
                end
            end

            if not liberou then
                Notify(source, "Você não tem permissão para fazer isso.", "error", 8)
                CancelEvent()
            end
        end
    end
end)