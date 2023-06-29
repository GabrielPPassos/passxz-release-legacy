local CurrentRequestId = 0
local ServerCallbacks = {}

RegisterNetEvent('Ponto:TriggerCallback')
AddEventHandler('Ponto:TriggerCallback', function(requestId, ...)
	if ServerCallbacks[requestId] then
		ServerCallbacks[requestId](...)
		ServerCallbacks[requestId] = nil
	end
end)

function TriggerCallback(name, cb, ...)
	ServerCallbacks[CurrentRequestId] = cb
	TriggerServerEvent("Ponto:TriggerCallback", name, CurrentRequestId, ...)
	if CurrentRequestId < 65535 then CurrentRequestId = CurrentRequestId + 1 else CurrentRequestId = 0 end
end