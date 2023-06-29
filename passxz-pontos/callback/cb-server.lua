local ServerCallbacks = {}

RegisterServerEvent("Ponto:TriggerCallback")
AddEventHandler('Ponto:TriggerCallback', function(name, requestId, ...)
	local src = source
	TriggerCallback(name, src, function(...)
		TriggerClientEvent("Ponto:TriggerCallback", src, requestId, ...)
	end, ...)
end)

function TriggerCallback(name, source, cb, ...)
	if ServerCallbacks[name] then
		ServerCallbacks[name](source, cb, ...)
	end
end

function CreateCallback(name, cb)
	ServerCallbacks[name] = cb
end