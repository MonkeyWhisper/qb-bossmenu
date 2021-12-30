local QBCore = exports['qb-core']:GetCoreObject()
local Accounts = {}

CreateThread(function()
	Wait(500)
	local bossmenu = exports.oxmysql:executeSync('SELECT * FROM bossmenu', {})
	if not bossmenu then
		return
	end
	for k,v in pairs(bossmenu) do
		local k = tostring(v.job_name)
		local v = tonumber(v.amount)
		if k and v then
			Accounts[k] = v
		end
	end
end)

RegisterNetEvent("qb-bossmenu:server:withdrawMoney", function(amount)
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)
	local job = xPlayer.PlayerData.job.name

	if not Accounts[job] then
		Accounts[job] = 0
	end

	if Accounts[job] >= amount and amount > 0 then
		Accounts[job] = Accounts[job] - amount
		xPlayer.Functions.AddMoney("cash", amount)
	else
		TriggerClientEvent('QBCore:Notify', src, "Importo non valido :/", "error")
		TriggerClientEvent('qb-bossmenu:client:mainmenu', src)
		return
	end
	
	exports.oxmysql:execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[job], job})
	TriggerEvent('qb-log:server:CreateLog', 'bossmenu', 'Withdraw Money', "blue", xPlayer.PlayerData.name.. "Prelievo $" .. amount .. ' (' .. job .. ')', true)
	TriggerClientEvent('QBCore:Notify', src, "Hai prelevato: $" ..amount, "success")
	TriggerClientEvent('qb-bossmenu:client:mainmenu', src)
end)

RegisterNetEvent("qb-bossmenu:server:depositMoney", function(amount)
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)
	local job = xPlayer.PlayerData.job.name

	if not Accounts[job] then
		Accounts[job] = 0
	end

	if xPlayer.Functions.RemoveMoney("cash", amount) then
		Accounts[job] = Accounts[job] + amount
	else
		TriggerClientEvent('QBCore:Notify', src, "Importo non valido :/", "error")
		TriggerClientEvent('qb-bossmenu:client:mainmenu', src)
		return
	end

	exports.oxmysql:execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[job], job })
	TriggerEvent('qb-log:server:CreateLog', 'bossmenu', 'Deposit Money', "blue", xPlayer.PlayerData.name.. "Deposito $" .. amount .. ' (' .. job .. ')', true)
	TriggerClientEvent('QBCore:Notify', src, "Hai depositato: $" ..amount, "success")
	TriggerClientEvent('qb-bossmenu:client:mainmenu', src)
end)
 
RegisterNetEvent("qb-bossmenu:server:addAccountMoney", function(account, amount)
	if not Accounts[account] then
		Accounts[account] = 0
	end

	Accounts[account] = Accounts[account] + amount
	exports.oxmysql:execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[account], account })
end)

RegisterNetEvent("qb-bossmenu:server:removeAccountMoney", function(account, amount)
	if not Accounts[account] then
		Accounts[account] = 0
	end

	if Accounts[account] >= amount then
		Accounts[account] = Accounts[account] - amount
	end

	exports.oxmysql:execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[account], account })
end)

QBCore.Functions.CreateCallback('qb-bossmenu:server:GetAccount', function(source, cb, jobname)
	local result = GetAccount(jobname)
	cb(result)
end)

-- Export
function GetAccount(account)
	return Accounts[account] or 0
end

-- Get Employees
QBCore.Functions.CreateCallback('qb-bossmenu:server:GetEmployees', function(source, cb, jobname)
	local src = source
	local employees = {}
	if not Accounts[jobname] then
		Accounts[jobname] = 0
	end
	local players = exports.oxmysql:executeSync("SELECT * FROM `players` WHERE `job` LIKE '%".. jobname .."%'", {})
	if players[1] ~= nil then
		for key, value in pairs(players) do
			local isOnline = QBCore.Functions.GetPlayerByCitizenId(value.citizenid)

			if isOnline then
				employees[#employees+1] = {
				empSource = isOnline.PlayerData.citizenid, 
				grade = isOnline.PlayerData.job.grade,
				isboss = isOnline.PlayerData.job.isboss,
				name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
				}
			else
				employees[#employees+1] = {
				empSource = value.citizenid, 
				grade =  json.decode(value.job).grade,
				isboss = json.decode(value.job).isboss,
				name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname  .. ' (Fuori città)'
				}
			end
		end
	end
	cb(employees)
end)

-- Grade Change
RegisterNetEvent('qb-bossmenu:server:aggiornaGrado', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Employee = QBCore.Functions.GetPlayerByCitizenId(data.cid)
	if Employee then
		if Employee.Functions.SetJob(Player.PlayerData.job.name, data.grado) then
			TriggerClientEvent('QBCore:Notify', src, "Grado cambiato con successo!", "success")
			TriggerClientEvent('QBCore:Notify', Employee.PlayerData.source, "Ora il tuo grado è " ..data.nomegrado..".", "success")
		else
			TriggerClientEvent('QBCore:Notify', src, "Questo grado non esiste", "error")
		end
	else
		TriggerClientEvent('QBCore:Notify', src, "Giocatore offline", "error")
	end
	TriggerClientEvent('qb-bossmenu:client:mainmenu', src)
end)

-- Fire Employee
RegisterNetEvent('qb-bossmenu:server:licenziaGiocatore', function(target)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Employee = QBCore.Functions.GetPlayerByCitizenId(target)
	if Employee then
		if Employee.Functions.SetJob("unemployed", '0') then
			TriggerEvent("qb-log:server:CreateLog", "bossmenu", "Job Fire", "red", Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. " " .. Employee.PlayerData.charinfo.lastname .. " (" .. Player.PlayerData.job.name .. ")", false)
			TriggerClientEvent('QBCore:Notify', src, "Dipendente licenziato!", "success")
			TriggerClientEvent('QBCore:Notify', Employee.PlayerData.source , "Sei stato licenziato", "error")
		else
			TriggerClientEvent('QBCore:Notify', src, "Errore..", "error")
		end
	else
		local player = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { target })
		if player[1] ~= nil then
			Employee = player[1]
			local job = {}
			job.name = "unemployed"
			job.label = "Disoccupato"
			job.payment = 500
			job.onduty = true
			job.isboss = false
			job.grade = {}
			job.grade.name = nil
			job.grade.level = 0
			exports.oxmysql:execute('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), target })
			TriggerClientEvent('QBCore:Notify', src, "Dipendente licenziato!", "success")
			TriggerEvent("qb-log:server:CreateLog", "bossmenu", "Job Fire", "red", Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. " " .. Employee.PlayerData.charinfo.lastname .. " (" .. Player.PlayerData.job.name .. ")", false)
		else
			TriggerClientEvent('QBCore:Notify', src, "Giocatore offline", "error")
		end
	end
	TriggerClientEvent('qb-bossmenu:client:mainmenu', src)
end)

-- Recruit Player
RegisterNetEvent('qb-bossmenu:server:reclutaGiocatore', function(recruit)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Target = QBCore.Functions.GetPlayer(recruit)
	if Player.PlayerData.job.isboss == true then
		if Target and Target.Functions.SetJob(Player.PlayerData.job.name, 0) then
			TriggerClientEvent('QBCore:Notify', src, "Hai assunto " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. " come " .. Player.PlayerData.job.label .. "", "success")
			TriggerClientEvent('QBCore:Notify', Target.PlayerData.source , "Sei stato assunto come " .. Player.PlayerData.job.label .. "", "success")
			TriggerEvent('qb-log:server:CreateLog', 'bossmenu', 'Recruit', "lightgreen", (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname).. " successfully recruited " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' (' .. Player.PlayerData.job.name .. ')', true)
		end
	end
	TriggerClientEvent('qb-bossmenu:client:mainmenu', src)
end)

-- Get closest player sv
QBCore.Functions.CreateCallback('qb-bossmenu:getplayers', function(source, cb)
	local src = source
	local players = {}
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	for k, v in pairs(QBCore.Functions.GetPlayers()) do
		local targetped = GetPlayerPed(v)
		local tCoords = GetEntityCoords(targetped)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= targetped and dist < 10 then
			local ped = QBCore.Functions.GetPlayer(v)
			players[#players+1] = {
			id = v,
			coords = GetEntityCoords(targetped),
			name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
			citizenid = ped.PlayerData.citizenid,
			sources = GetPlayerPed(ped.PlayerData.source),
			sourceplayer = ped.PlayerData.source
			}
		end
	end
		table.sort(players, function(a, b)
			return a.name < b.name
		end)
	cb(players)
end)