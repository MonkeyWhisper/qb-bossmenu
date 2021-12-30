local QBCore = exports['qb-core']:GetCoreObject()
local PlayerGang = {}
local shownGangMenu = false

AddEventHandler('onResourceStart', function(resource) --if you restart the resource
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerGang = QBCore.Functions.GetPlayerData().gang
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerGang = QBCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(InfoGang)
    PlayerGang = InfoGang
end)

RegisterNetEvent('qb-gangmenu:client:inventario', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "Inv_" .. PlayerGang.label, {
        maxweight = 5000000,
        slots = 100,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "Inv_" .. PlayerGang.label)
end)

RegisterNetEvent('qb-gangmenu:client:guardaroba', function()
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end)

RegisterNetEvent('qb-gangmenu:client:mainmenu', function()
	shownGangMenu = true
	local gangMenu = {
			{
				header = "Gang Management  - " ..string.upper(PlayerGang.label),
				isMenuHeader = true,
			},
			{
				header = "Manage Gang Members",
				txt = "Recruit or Fire Gang Members",
				params = {
					event = "qb-gangmenu:client:gestiscidipendenti",
				}
			},
			{
				header = "Recruit Members",
				txt = "Hire Gang Members",
				params = {
					event = "qb-gangmenu:client:assumidipendenti",
				}
			},
			{
				header = "Storage",
				txt = "Open Gang Stash",
				params = {
					event = "qb-gangmenu:client:inventario",
				}
			},
			{
				header = "Outfits",
				txt = "See Saved Outfits",
				params = {
					event = "qb-gangmenu:client:guardaroba",
				}
			},
			{
				header = "Gang Balance",
				txt = "See Gang Bank Account",
				params = {
					event = "qb-gangmenu:client:saldosocieta",
				}
			},
			{
				header = "Exit",
				params = {
					event = "qb-menu:closeMenu",
				}
			},
		}
	exports['qb-menu']:openMenu(gangMenu)
end)

RegisterNetEvent('qb-gangmenu:client:gestiscidipendenti', function()
	local dipendentiMenuGang = {
		{
			header = "Manage Gang Members - " ..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-gangmenu:server:GetEmployees', function(cb)
        for k,v in pairs(cb) do			
			dipendentiMenuGang[#dipendentiMenuGang+1] = {
				header = v.name,
				txt = v.grade.name,
				params = {
					event = "qb-gangmenu:client:gestiscidipendente",
					args = {
						giocatore = v,
						lavoro = PlayerGang
					}
				}
			}
        end
		dipendentiMenuGang[#dipendentiMenuGang+1] = {
			header = "< Return",
			params = {
				event = "qb-gangmenu:client:mainmenu",
			}
		}
	exports['qb-menu']:openMenu(dipendentiMenuGang)
    end, PlayerGang.name)
end)

RegisterNetEvent('qb-gangmenu:client:gestiscidipendente', function(data)
	local dipendenteMenuGang = {
		{
			header = "Manage " ..data.giocatore.name.. " - " ..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
	}
	for k, v in pairs(QBCore.Shared.Gangs[data.lavoro.name].grades) do
		dipendenteMenuGang[#dipendenteMenuGang+1] = {
			header = v.name,
			txt = "Grade: " ..k,
			params = {
				isServer = true,
				event = "qb-gangmenu:server:aggiornaGrado",
				args = {
					cid = data.giocatore.empSource,
					grado = tonumber(k),
					nomegrado = v.name
				}
			}
		}
	end
	dipendenteMenuGang[#dipendenteMenuGang+1] = {
		header = "Fire",
		params = {
			isServer = true,
			event = "qb-gangmenu:server:licenziaGiocatore",
			args = data.giocatore.empSource
		}
	}
	dipendenteMenuGang[#dipendenteMenuGang+1] = {
		header = "< Return",
		params = {
			event = "qb-gangmenu:client:gestiscidipendenti",
		}
	}
	exports['qb-menu']:openMenu(dipendenteMenuGang)
end)

RegisterNetEvent('qb-gangmenu:client:assumidipendenti', function()
	local assumidipendentiMenuGang = {
		{
			header = "Hire Gang Members - " ..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-gangmenu:getplayers', function(players)
		for k,v in pairs(players) do
			if v and v ~= PlayerId() then
				assumidipendentiMenuGang[#assumidipendentiMenuGang+1] = {
					header = v.name,
					txt = "Citizen ID: " ..v.citizenid.. " - ID: " ..v.sourceplayer,
					params = {
						isServer = true,
						event = "qb-gangmenu:server:reclutaGiocatore",
						args = v.sourceplayer
					}
				}
			end
		end
		assumidipendentiMenuGang[#assumidipendentiMenuGang+1] = {
			header = "< Return",
			params = {
				event = "qb-gangmenu:client:mainmenu",
			}
		}
		exports['qb-menu']:openMenu(assumidipendentiMenuGang)
	end)
end)

RegisterNetEvent('qb-gangmenu:client:saldosocieta', function()
	QBCore.Functions.TriggerCallback('qb-gangmenu:server:GetAccount', function(cb)	
	local menuSaldosocieta = {
		{
			header = "Balance: $" .. comma_valueGang(cb) .. " - "..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
		{
			header = "Deposit",
			txt = "Deposit Money",
			params = {
				event = "qb-gangmenu:client:depositadenaro",
				args = comma_valueGang(cb)
			}
		},
		{
			header = "Withdraw",
			txt = "Withdraw Money",
			params = {
				event = "qb-gangmenu:client:prelevadenaro",
				args = comma_valueGang(cb)
			}
		},
		{
			header = "< Return",
			params = {
				event = "qb-gangmenu:client:mainmenu",
			}
		},
	}
		exports['qb-menu']:openMenu(menuSaldosocieta)
	end, PlayerGang.name)
end)

RegisterNetEvent('qb-gangmenu:client:depositadenaro', function(saldoattuale)
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
		TriggerServerEvent("qb-gangmenu:server:depositMoney", tonumber(depositadenaro.amount))
	end
end)

RegisterNetEvent('qb-gangmenu:client:prelevadenaro', function(saldoattuale)
	local prelevadenaro = exports['qb-input']:ShowInput({
		header = "Withdraw Money <br> Available Balance: $" ..saldoattuale,
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
	if prelevadenaro then
		if not prelevadenaro.amount then return end
		TriggerServerEvent("qb-gangmenu:server:withdrawMoney", tonumber(prelevadenaro.amount))
	end
end)

-- MAIN THREAD
CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local inRangeGang = false
		local nearGangmenu = false
		for k, v in pairs(Config.Gangs) do
			if k == PlayerGang.name and PlayerGang.isboss then
				if #(pos - v) < 5.0 then
					inRangeGang = true
						if #(pos - v) <= 1.5 then
							if not shownGangMenu then DrawText3DGang(v, "~b~E~w~ - Open Gang Management") end
							nearGangmenu = true
							if IsControlJustReleased(0, 38) then
								TriggerEvent("qb-gangmenu:client:mainmenu")
							end
						end

					if not nearGangmenu and shownGangMenu then
						CloseMenuFull()
						shownGangMenu = false
					end
				end
			end
		end
			if not inRangeGang then
				Wait(1500)
				if shownGangMenu then
					CloseMenuFullGang()
					shownGangMenu = false
				end
			end
	Wait(5)
	end
end)

-- UTIL
function CloseMenuFullGang()
    exports['qb-menu']:closeMenu()
	shownGangMenu = false
end

function DrawText3DGang(v, text)
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

function comma_valueGang(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end
