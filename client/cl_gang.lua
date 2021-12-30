local QBCore = exports['qb-core']:GetCoreObject()
local PlayerGang = {}
local shownGangMenu = false

--[[AddEventHandler('onResourceStart', function(resource) --if you restart the resource
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerGang = QBCore.Functions.GetPlayerData().gang
    end
end)]]

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
				header = "Menù Fazione - " ..string.upper(PlayerGang.label),
				isMenuHeader = true,
			},
			{
				header = "Gestisci Affiliati",
				txt = "Gestisci i tuoi affiliati, puoi farli fuori o cambiargli il grado",
				params = {
					event = "qb-gangmenu:client:gestiscidipendenti",
				}
			},
			{
				header = "Assumi Affiliati",
				txt = "Puoi affiliare i giocatori nei paraggi",
				params = {
					event = "qb-gangmenu:client:assumidipendenti",
				}
			},
			{
				header = "Inventario",
				txt = "Apri l'inventario della fazione",
				params = {
					event = "qb-gangmenu:client:inventario",
				}
			},
			{
				header = "Guardaroba",
				txt = "Apri il tuo guardaroba",
				params = {
					event = "qb-gangmenu:client:guardaroba",
				}
			},
			{
				header = "Saldo Fazione",
				txt = "Gestisci il saldo della fazione, puoi prelevare o depositare denaro",
				params = {
					event = "qb-gangmenu:client:saldosocieta",
				}
			},
			{
				header = "Chiudi",
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
			header = "Gestisci Affiliati - " ..string.upper(PlayerGang.label),
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
			header = "< Indietro",
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
			header = "Gestisci " ..data.giocatore.name.. " - " ..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
	}
	for k, v in pairs(QBCore.Shared.Gangs[data.lavoro.name].grades) do
		dipendenteMenuGang[#dipendenteMenuGang+1] = {
			header = v.name,
			txt = "Grado: " ..k,
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
		header = "Butta fuori",
		params = {
			isServer = true,
			event = "qb-gangmenu:server:licenziaGiocatore",
			args = data.giocatore.empSource
		}
	}
	dipendenteMenuGang[#dipendenteMenuGang+1] = {
		header = "< Indietro",
		params = {
			event = "qb-gangmenu:client:gestiscidipendenti",
		}
	}
	exports['qb-menu']:openMenu(dipendenteMenuGang)
end)

RegisterNetEvent('qb-gangmenu:client:assumidipendenti', function()
	local assumidipendentiMenuGang = {
		{
			header = "Assumi dipendenti - " ..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-gangmenu:getplayers', function(players)
		for k,v in pairs(players) do
			if v and v ~= PlayerId() then
				assumidipendentiMenuGang[#assumidipendentiMenuGang+1] = {
					header = v.name,
					txt = "CID: " ..v.citizenid.. " - ID: " ..v.sourceplayer,
					params = {
						isServer = true,
						event = "qb-gangmenu:server:reclutaGiocatore",
						args = v.sourceplayer
					}
				}
			end
		end
		assumidipendentiMenuGang[#assumidipendentiMenuGang+1] = {
			header = "< Indietro",
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
			header = "Saldo: $" .. comma_valueGang(cb) .. " - "..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
		{
			header = "Deposita",
			txt = "Deposita denaro nella cassaforte della tua fazione",
			params = {
				event = "qb-gangmenu:client:depositadenaro",
				args = comma_valueGang(cb)
			}
		},
		{
			header = "Preleva",
			txt = "Preleva denaro dalla cassaforte della tua fazione",
			params = {
				event = "qb-gangmenu:client:prelevadenaro",
				args = comma_valueGang(cb)
			}
		},
		{
			header = "< Indietro",
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
		header = "Deposita Denaro <br> Saldo Attuale: $" ..saldoattuale,
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
	if depositadenaro then
		if not depositadenaro.amount then return end
		TriggerServerEvent("qb-gangmenu:server:depositMoney", tonumber(depositadenaro.amount))
	end
end)

RegisterNetEvent('qb-gangmenu:client:prelevadenaro', function(saldoattuale)
	local prelevadenaro = exports['qb-input']:ShowInput({
		header = "Preleva Denaro <br> Saldo Attuale: $" ..saldoattuale,
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
							if not shownGangMenu then DrawText3DGang(v, "~b~E~w~ - Menu Fazione") end
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