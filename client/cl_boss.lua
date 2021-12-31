local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
local shownBossMenu = false

AddEventHandler('onResourceStart', function(resource) --if you restart the resource
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('qb-bossmenu:client:inventario', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "boss_" .. PlayerJob.label, {
        maxweight = 4000000,
        slots = 100,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "boss_" .. PlayerJob.label)
end)

RegisterNetEvent('qb-bossmenu:client:guardaroba', function()
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end)

RegisterNetEvent('qb-bossmenu:client:mainmenu', function()
	shownBossMenu = true
	local bossMenu = {
			{
				header = "Boss Menu - " ..string.upper(PlayerJob.label),
				isMenuHeader = true,
			},
			{
				header = "Manage Employees",
				txt = "Fire or Promote Employees",
				params = {
					event = "qb-bossmenu:client:gestiscidipendenti",
				}
			},
			{
				header = "Hire Employees",
				txt = "Hire Nearby Civilians",
				params = {
					event = "qb-bossmenu:client:assumidipendenti",
				}
			},
			{
				header = "Storage",
				txt = "Open Storage",
				params = {
					event = "qb-bossmenu:client:inventario",
				}
			},
			{
				header = "Outfits",
				txt = "See Saved Outfits",
				params = {
					event = "qb-bossmenu:client:guardaroba",
				}
			},
			{
				header = "Money Management",
				txt = "Deposit or Withdrawl",
				params = {
					event = "qb-bossmenu:client:saldosocieta",
				}
			},
			{
				header = "Exit",
				params = {
					event = "qb-menu:closeMenu",
				}
			},
		}
	exports['qb-menu']:openMenu(bossMenu)
end)

RegisterNetEvent('qb-bossmenu:client:gestiscidipendenti', function()
	local dipendentiMenu = {
		{
			header = "Manage Employees - " ..string.upper(PlayerJob.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-bossmenu:server:GetEmployees', function(cb)
        for k,v in pairs(cb) do			
			dipendentiMenu[#dipendentiMenu+1] = {
				header = v.name,
				txt = v.grade.name,
				params = {
					event = "qb-bossmenu:client:gestiscidipendente",
					args = {
						giocatore = v,
						lavoro = PlayerJob
					}
				}
			}
        end
		dipendentiMenu[#dipendentiMenu+1] = {
			header = "< Return",
			params = {
				event = "qb-bossmenu:client:mainmenu",
			}
		}
	exports['qb-menu']:openMenu(dipendentiMenu)
    end, PlayerJob.name)
end)

RegisterNetEvent('qb-bossmenu:client:gestiscidipendente', function(data)
	local dipendenteMenu = {
		{
			header = "Manage " ..data.giocatore.name.. " - " ..string.upper(PlayerJob.label),
			isMenuHeader = true,
		},
	}
	for k, v in pairs(QBCore.Shared.Jobs[data.lavoro.name].grades) do
		dipendenteMenu[#dipendenteMenu+1] = {
			header = v.name,
			txt = "Grade: " ..k,
			params = {
				isServer = true,
				event = "qb-bossmenu:server:aggiornaGrado",
				args = {
					cid = data.giocatore.empSource,
					grado = tonumber(k),
					nomegrado = v.name
				}
			}
		}
	end
	dipendenteMenu[#dipendenteMenu+1] = {
		header = "Fire",
		params = {
			isServer = true,
			event = "qb-bossmenu:server:licenziaGiocatore",
			args = data.giocatore.empSource
		}
	}
	dipendenteMenu[#dipendenteMenu+1] = {
		header = "< Return",
		params = {
			event = "qb-bossmenu:client:gestiscidipendenti",
		}
	}
	exports['qb-menu']:openMenu(dipendenteMenu)
end)

RegisterNetEvent('qb-bossmenu:client:assumidipendenti', function()
	local assumidipendentiMenu = {
		{
			header = "Hire Employees - " ..string.upper(PlayerJob.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-bossmenu:getplayers', function(players)
		for k,v in pairs(players) do
			if v and v ~= PlayerId() then
				assumidipendentiMenu[#assumidipendentiMenu+1] = {
					header = v.name,
					txt = "Citizen ID: " ..v.citizenid.. " - ID: " ..v.sourceplayer,
					params = {
						isServer = true,
						event = "qb-bossmenu:server:reclutaGiocatore",
						args = v.sourceplayer
					}
				}
			end
		end
		assumidipendentiMenu[#assumidipendentiMenu+1] = {
			header = "< Return",
			params = {
				event = "qb-bossmenu:client:mainmenu",
			}
		}
		exports['qb-menu']:openMenu(assumidipendentiMenu)
	end)
end)

RegisterNetEvent('qb-bossmenu:client:saldosocieta', function()
	QBCore.Functions.TriggerCallback('qb-bossmenu:server:GetAccount', function(cb)	
	local menuSaldosocieta = {
		{
			header = "Balance: $" .. comma_value(cb) .. " - "..string.upper(PlayerJob.label),
			isMenuHeader = true,
		},
		{
			header = "Deposit",
			txt = "Deposit Money",
			params = {
				event = "qb-bossmenu:client:depositadenaro",
				args = comma_value(cb)
			}
		},
		{
			header = "Withdraw",
			txt = "Withdraw Money",
			params = {
				event = "qb-bossmenu:client:prelevadenaro",
				args = comma_value(cb)
			}
		},
		{
			header = "< Return",
			params = {
				event = "qb-bossmenu:client:mainmenu",
			}
		},
	}
		exports['qb-menu']:openMenu(menuSaldosocieta)
	end, PlayerJob.name)
end)

RegisterNetEvent('qb-bossmenu:client:depositadenaro', function(saldoattuale)
	local depositadenaro = exports['qb-input']:ShowInput({
		header = "Deposit Money <br> Available Balance: $" ..saldoattuale,
		submitText = "Confirm",
		inputs = {
			{
				type = 'number',
				isRequired = true,
				name = 'amount',
				text = '$'
			}
		}
	})
	if depositadenaro then
		if not depositadenaro.amount then return end
		TriggerServerEvent("qb-bossmenu:server:depositMoney", tonumber(depositadenaro.amount))
	end
end)

RegisterNetEvent('qb-bossmenu:client:prelevadenaro', function(saldoattuale)
	local prelevadenaro = exports['qb-input']:ShowInput({
		header = "Withdraw Money <br> Available Balance: $" ..saldoattuale,
		submitText = "Conferma",
		inputs = {
			{
				type = 'number',
				isRequired = true,
				name = 'amount',
				text = '$'
			}
		}
	})
	if prelevadenaro then
		if not prelevadenaro.amount then return end
		TriggerServerEvent("qb-bossmenu:server:withdrawMoney", tonumber(prelevadenaro.amount))
	end
end)

-- MAIN THREAD
CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local inRangeBoss = false
		local nearBossmenu = false
		for k, v in pairs(Config.Jobs) do
			if k == PlayerJob.name and PlayerJob.isboss then
				if #(pos - v) < 5.0 then
					inRangeBoss = true
						if #(pos - v) <= 1.5 then
							if not shownBossMenu then DrawText3D(v, "~b~E~w~ - Open Boss Menu") end
							nearBossmenu = true
							if IsControlJustReleased(0, 38) then
								TriggerEvent("qb-bossmenu:client:mainmenu")
							end
						end

					if not nearBossmenu and shownBossMenu then
						CloseMenuFull()
						shownBossMenu = false
					end
				end
			end
		end
			if not inRangeBoss then
				Wait(1500)
				if shownBossMenu then
					CloseMenuFull()
					shownBossMenu = false
				end
			end
	Wait(5)
	end
end)

-- UTIL
function CloseMenuFull()
    exports['qb-menu']:closeMenu()
	shownBossMenu = false
end

function DrawText3D(v, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(v, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 0)
    ClearDrawOrigin()
end

function comma_value(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end
