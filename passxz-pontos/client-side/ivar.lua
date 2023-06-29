local Cooldown = 0
local status = "false"

local Coords = {
    { org = "Policia",       coords = vector3(-2083.47,-516.30,12.22) },
    { org = "Policia",       coords = vector3(-1753.04,-783.96,11.73) },
    { org = "Policia Civil", coords = vector3(2511.62,-355.74,94.09) },
    { org = "SAMU",          coords = vector3(-435.87,-325.84,34.91) },
}

function getLocal()
	local locais = Coords
	local playercoords = GetEntityCoords(PlayerPedId())
	for k,v in pairs(Coords) do
		local distance = #(playercoords - v.coords )
		if distance < 3 then
			return v.org
		end
	end
	return false
end

RegisterNetEvent("empire_ponto:atualizarStatus")
AddEventHandler("empire_ponto:atualizarStatus", function(x)
    status = x 
end)

RegisterNetEvent("empire_ponto:iniciarCooldown")
AddEventHandler("empire_ponto:iniciarCooldown", function(x)
    Cooldown = 300
end)

Citizen.CreateThread(function()
	local innerTable = {}
	for k,v in pairs(Coords) do
		local coooords = v.coords
		table.insert(innerTable,{ coooords[1],coooords[2],coooords[3],1,"E","Expediente","Pressione para <b>iniciar/encerrar</b>." })
	end

	TriggerEvent("hoverfy:insertTable",innerTable)
end)

Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		local ped = PlayerPedId()
		if not IsPedInAnyVehicle(ped) then
            for k,v in pairs(Coords) do
                local coords = GetEntityCoords(ped)
                local startDis = #(coords - v.coords)
                if startDis <= 5 then
                    timeDistance = 4
                    local coooords = v.coords
                    if startDis <= 1.1 and IsControlJustPressed(1,38) then
						DrawMarker(21,coooords[1],coooords[2],coooords[3] + 0.25,0.0,0.0,0.0,0.0,180.0,0.0,0.25,0.35,0.25,46,110,76,100,0,0,0,1)  
						if Cooldown <= 0 then
                        	TriggerServerEvent("empire_ponto:servico", getLocal())
						else
							TriggerEvent("pNotify:SendNotification",{text = "Aguarde <b>".. Cooldown .." segundos</b> para encerrar o seu <b>expediente</b>.", type = "info", timeout = (8000),layout = "centerLeft"})
						end
                    end
                end
            end
		end
		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		local timeDistance = 1000
        if Cooldown > 0 then
            Cooldown = Cooldown - 1
        end
		Citizen.Wait(timeDistance)
	end
end)