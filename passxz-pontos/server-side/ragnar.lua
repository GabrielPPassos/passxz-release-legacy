------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÕES:VRP
------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DB:MYSQL
------------------------------------------------------------------------------------------------------------------------------------------------------------------
MySQL = exports["ghmattimysql"]
vrp_insert_pontos = "INSERT INTO vrp_pontos (user_id, job, entry_time, status) VALUES (@user_id, @job, NOW(), 0)"
vrp_update_pontos = "UPDATE vrp_pontos SET exit_time = NOW() WHERE user_id = @user_id AND exit_time IS NULL"
vrp_update_pontos_status = "UPDATE vrp_pontos SET status = @status WHERE user_id = @user_id AND id = @id"
vrp_select_pontos = "SELECT * FROM vrp_pontos WHERE user_id = @user_id"
vrp_select_ponto_atual = "SELECT * FROM vrp_pontos WHERE user_id = @user_id AND exit_time IS NULL"
vrp_update_ponto_atual = "UPDATE vrp_pontos SET exit_time = @exit_time, status = @status WHERE user_id = @user_id AND exit_time IS NULL"
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TABLES
------------------------------------------------------------------------------------------------------------------------------------------------------------------
local guardarSource = {}
local emServico = {}
local pontos = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--# Configurações de Grupos e Organizações
local Jobs = {
    ["Policia"] = {
        "Comandante - Geral",
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

    ["Policia Civil"] = {
        "Delegado Geral - PC",
        "Delegado - PC",
        "Comissario - PC",
        "Agente 1C - PC",
        "Agente 2C - PC",
        "Agente 3C - PC",
        "Inspetor - DEIC",
        "Perito Criminal - DEIC",
        "Investigador 1C - DEIC",
        "Investigador 2C - DEIC",
    },
    
    ["SAMU"] = {
        "Diretor - SAMU",
        "Vice Diretor - SAMU",
        "Medico Chefe - SAMU",
        "Medico - SAMU",
        "Paramedico - SAMU",
        "Enfermeiro - SAMU",
    }
}
--# Configurações de Grupos Que Podem Gerenciar os Pontos
local Comandantes = {
    ["Policia"] = {
        "Comandante - Geral",
        "Comandante - Policia Militar", 
        "Capitao - Policia Militar",  
        "Comandante - FT", 
        "Capitao - FT",  
        "Comandante - ROTA", 
        "Capitao - ROTA",  
    },

    ["Policia Civil"] = {
        "Delegado Geral - PC",
        "Delegado - PC",
    },
    
    ["SAMU"] = {
        "Diretor - SAMU",
        "Vice Diretor - SAMU",
    }
}
--# Configurações de Tags Que Aparecerão no Discord
local Tags = {
    { ['group'] = "Comandante - Geral", ['tag'] = "[CMD-GERAL]" },

    { ['group'] = "Comandante - Policia Militar", ['tag'] = "[RPM][CMD.]" }, 
    { ['group'] = "Capitao - Policia Militar", ['tag'] = "[RPM][CAP.]" },  
    { ['group'] = "Tenente - Policia Militar", ['tag'] = "[RPM][TEN.]" },
    { ['group'] = "Sargento - Policia Militar", ['tag'] = "[RPM][SGT.]" },
    { ['group'] = "Cabo - Policia Militar", ['tag'] = "[RPM][CB.]" },
    { ['group'] = "Soldado - Policia Militar", ['tag'] = "[RPM][SD.]" },
    { ['group'] = "Recruta - Policia Militar", ['tag'] = "[RPM][ST.]" },

    { ['group'] = "Comandante - FT", ['tag'] = "[FT][CMD.]" }, 
    { ['group'] = "Capitao - FT", ['tag'] = "[FT][CAP.]" },
    { ['group'] = "Tenente - FT", ['tag'] = "[FT][TEN.]" },
    { ['group'] = "Sargento - FT", ['tag'] = "[FT][SGT.]" },
    { ['group'] =  "Cabo - FT", ['tag'] = "[FT][CB.]" },
    { ['group'] = "Soldado - FT", ['tag'] = "[FT][SD.]" },
    { ['group'] =  "Recruta - FT", ['tag'] = "[FT][ST.]" },
    
    { ['group'] = "Comandante - ROTA", ['tag'] = "[ROTA][CMD.]" }, 
    { ['group'] = "Capitao - ROTA", ['tag'] = "[ROTA][CAP.]" },
    { ['group'] = "Tenente - ROTA", ['tag'] = "[ROTA][TEN.]" },
    { ['group'] = "Sargento - ROTA", ['tag'] = "[ROTA][SGT.]" },
    { ['group'] = "Cabo - ROTA", ['tag'] = "[ROTA][CB.]" },
    { ['group'] = "Soldado - ROTA", ['tag'] = "[ROTA][SD.]" },
    { ['group'] = "Recruta - ROTA", ['tag'] = "[ROTA][ST.]" },

    { ['group'] = "Delegado Geral - PC", ['tag'] = "[DEL-GERAL.]" },
    { ['group'] = "Delegado - PC", ['tag'] = "[PC][DEL.]" },

    { ['group'] = "Comissario - PC", ['tag'] = "[PC][COM.]" },
    { ['group'] = "Agente 1C - PC", ['tag'] = "[PC][AG. 1ªC]" },
    { ['group'] = "Agente 2C - PC", ['tag'] = "[PC][AG. 2ªC]" },
    { ['group'] = "Agente 3C - PC", ['tag'] = "[PC][AG. 3ªC]" },

    { ['group'] = "Inspetor - DEIC", ['tag'] = "[GARRA][INSP.]" },
    { ['group'] = "Perito Criminal - DEIC", ['tag'] = "[GARRA][Perito C.]" },
    { ['group'] = "Investigador 1C - DEIC", ['tag'] = "[GARRA][AG. 1ªC]" },
    { ['group'] = "Investigador 2C - DEIC", ['tag'] = "[GARRA][AG. 2ªC]" },

    { ['group'] = "Diretor - SAMU", ['tag'] = "[SAMU][Dir.]" },
    { ['group'] = "Vice Diretor - SAMU", ['tag'] = "[SAMU][Vice Dir.]" },
    { ['group'] = "Medico Chefe - SAMU", ['tag'] = "[SAMU][Medico C.]" },
    { ['group'] = "Medico - SAMU", ['tag'] = "[SAMU][Med.]" },
    { ['group'] = "Paramedico - SAMU", ['tag'] = "[SAMU][Param.]" },
    { ['group'] = "Enfermeiro - SAMU", ['tag'] = "[SAMU][Enf.]" },
}
--# Configurações dos WebHooks
local Webhooks = {
    ["Policia"] = GetConvar("pontosPM", "none"),
    ["Policia Civil"] = GetConvar("pontosPC", "none"),
    ["SAMU"] = GetConvar("pontosSAMU", "none"),
}
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS:MISC
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Notify(source, txt, css, time)
    TriggerClientEvent("pNotify:SendNotification",source, {text = txt, type = css, timeout = (time*1000), layout = "centerLeft"})
end
function parseDateTime(dateTimeString)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = dateTimeString:match(pattern)
    return {year=year, month=month, day=day, hour=hour, min=min, sec=sec}
end
function converterSegundosParaHoras(segundos)
    local horas = math.floor(segundos / 3600)
    local minutos = math.floor((segundos % 3600) / 60)
    local segundosRestantes = segundos % 60

    local tempoFormatado = string.format("%02d:%02d:%02d", horas, minutos, segundosRestantes)
    return tempoFormatado
end
function getDiscordTags(group)
    for k,v in pairs(Tags) do
        if v.group == group then
            return v.tag
        end
    end
end
function getPlayersInService(webhook)
    local playersInService = "Nenhum jogador em serviço."
    for k,v in pairs(emServico) do
        if playersInService == "Nenhum jogador em serviço." then
            playersInService = emServico[k].hora .. " | ".. getDiscordTags(emServico[k].group) .." ".. emServico[k].nome .." - ".. k .." | NORMAL\n"
        else
            playersInService = playersInService .. "".. emServico[k].hora .. " | ".. getDiscordTags(v.group) .." ".. emServico[k].nome .." - ".. k .." | NORMAL\n"
        end
    end

    if webhook ~= "none" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content =  '```'.. playersInService ..'```'}), { ['Content-Type'] = 'application/json' })
	end
end
function registrarEntrada(source)
    local src = source
    local user_id = vRP.getUserId({src})
    local currentTime = os.time()

    for k,v in pairs(Jobs) do
        for _,group in pairs(Jobs[k]) do
            if group == vRP.getUserGroupByType({vRP.getUserId({source}), "job"}) then
                MySQL:execute(vrp_insert_pontos, { user_id = user_id, job = k})
                pontos[user_id] = true
                TriggerClientEvent("empire_ponto:atualizarStatus", src, "on")
                TriggerClientEvent("empire_ponto:iniciarCooldown", src)
                vRP.getUserIdentity({user_id, function(identity)
                    if identity then
                        emServico[user_id] = {
                            job = k,
                            group = vRP.getUserGroupByType({vRP.getUserId({source}), "job"}),
                            hora = os.date("%H:%M"),
                            nome = identity.firstname .." ".. identity.name
                        }

                        getPlayersInService(Webhooks[k])
                    end
                end})

                return true
            end
        end
    end
    
    return false
end
function registrarSaida(source)
    local src = source
    local user_id = vRP.getUserId({src})
    local currentTime = os.time()

    MySQL:execute(vrp_select_ponto_atual, { user_id = user_id }, function(rows)
        if #rows > 0 then
            MySQL:execute(vrp_update_ponto_atual, { user_id = user_id, exit_time = os.date("%Y-%m-%d %H:%M:%S", currentTime), status = 1 })
            pontos[user_id] = nil 
            emServico[user_id] = nil
            TriggerClientEvent("empire_ponto:atualizarStatus", src, "false")
            for k,v in pairs(Jobs) do
                for _,group in pairs(Jobs[k]) do
                    if group == vRP.getUserGroupByType({vRP.getUserId({source}), "job"}) then
                        getPlayersInService(Webhooks[k])
                    end
                end
            end
            return true
        end
    end)
end
function isComandante(source)
    for k,v in pairs(Comandantes) do
        for a,b in pairs(Comandantes[k]) do
            if b == vRP.getUserGroupByType({vRP.getUserId({source}), "job"}) then
                return true, k
            end
        end
    end
    return false
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
-- CALLBACKS
------------------------------------------------------------------------------------------------------------------------------------------------------------------
CreateCallback("empire_ponto:checkStatus", function(source, cb)
    local source = source
    local user_id = vRP.getUserId({source})

    if #pontos > 0 then
        if pontos[user_id] then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('chatMessageEntered')
AddEventHandler('chatMessageEntered', function(name, color, message)
    local source = source
	
	if message:sub(1, 1) == "/" then
		fullcmd = stringSplit(message, " ")
		cmd = fullcmd[1]
        local msg = fullcmd[2]
		for k,v in ipairs(fullcmd) do
			if k > 2 then
				msg = msg .. " " .. fullcmd[k]
			end
		end

        if cmd == "/calcular" then
			local source = source
			local user_id = vRP.getUserId({source})
            local islider,organizacao = isComandante(source)

            if islider then
                local nuser_id = tonumber(msg)
                MySQL:execute(vrp_select_pontos, { user_id = nuser_id }, function(rows)
                    if #rows > 0 then
                        local patrolDuration = 0
                        for k,v in pairs(rows) do
                            if v.job == organizacao then
                                if v.status == 1 then
                                    local entryTime = os.time(parseDateTime(v.entry_time))
                                    local exitTime = os.time(parseDateTime(v.exit_time))
                                    patrolDuration = patrolDuration + exitTime - entryTime    
                                end
                            else
                                Notify(source, "O passaporte <b>".. nuser_id .."</b> não pertence a sua organização <b>(".. organizacao ..")</b>.", "error", 8)
                                return
                            end
                        end
                        Notify(source, "O <b>passaporte ".. nuser_id .."</b> trabalhou no total: <b>".. converterSegundosParaHoras(patrolDuration) .." horas</b>.", "success", 8)
                    else
                        Notify(source, "O passaporte <b>".. nuser_id .."</b> não possui nenhum ponto para calcular.", "error", 8)
                    end
                end)
            end
        end

        if cmd == "/pontos" then
			local source = source
			local user_id = vRP.getUserId({source})
            guardarSource[user_id] = vRP.getUserSource({user_id})
            local islider,organizacao = isComandante(source)

            if islider then
                local nuser_id = tonumber(msg)
                vRP.getUserIdentity({nuser_id, function(identity)
                    if identity then
                        MySQL:execute(vrp_select_pontos, { user_id = nuser_id }, function(rows)
                            vRP.buildMenu({"vRPpontos", {player = guardarSource[user_id]}, function(menu)
                                if #rows > 0 then
                                    for k,v in pairs(rows) do
                                        if v.job == organizacao then
                                            menu.name = identity.firstname .." ".. identity.name .." (".. nuser_id ..")"

                                            local description = "Entrada: "..v.entry_time.." - Saída: "..v.exit_time

                                            local status 
                                            if tonumber(v.status) == 0 then
                                                status = "Negativado"
                                            elseif tonumber(v.status) == 1 then
                                                status = "Aprovado"
                                            end

                                            menu["PONTO: ".. v.id .." | ".. status] = {function(player, choice)
                                                vRP.buildMenu({"vRPpontosger", {player = guardarSource[user_id]}, function(menu_gerenciamento)
                                                    menu_gerenciamento.name = "Gerenciar Ponto"

                                                    if tonumber(v.status) == 0 then
                                                        menu_gerenciamento["Aprovar"] = {function(player, choice)
                                                            MySQL:execute(vrp_update_pontos_status, {user_id = nuser_id, id = v.id, status = 1})
                                                            Notify(player, "Você <b>aprovou</b> esse ponto.", "success", 8)
                                                        end}
                                                    elseif tonumber(v.status) == 1 then
                                                        menu_gerenciamento["Negativar"] = {function(player, choice)
                                                            MySQL:execute(vrp_update_pontos_status, {user_id = nuser_id, id = v.id, status = 0 })
                                                            Notify(player, "Você <b>negativou</b> esse ponto.", "error", 8)
                                                        end}
                                                    end
                                
                                                    vRP.openMenu({player,menu_gerenciamento})
                                                end})
                                            end, description}
                                        else
                                            Notify(guardarSource[user_id], "O passaporte <b>".. nuser_id .."</b> não pertence a sua organização <b>(".. organizacao ..")</b>.", "error", 8)
                                            vRP.closeMenu({guardarSource[user_id], menu})
                                            return
                                        end
                                    end
                                else
                                    menu['Nenhum ponto encontrado.'] = {function(player, choice)
                                        -- 
                                    end}
                                end
                                vRP.openMenu({guardarSource[user_id],menu})
                            end})
                        end)
                    end
                end})

            end
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("empire_ponto:servico")
AddEventHandler("empire_ponto:servico", function(locais)
    local source = source
    local user_id = vRP.getUserId({source})

    for _,group in pairs(Jobs[locais]) do
        if group == vRP.getUserGroupByType({user_id, "job"}) then
            if pontos[user_id] then
               registrarSaida(source)
               Notify(source, "Você bateu o seu ponto e saiu de serviço.", "info", 8)
               return
            else
                registrarEntrada(source) 
                Notify(source, "Você bateu o seu ponto e entrou de serviço.", "success", 8)
                return
            end
        end
    end
end)