require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'BuyTank_')) then  --look for the order that we inserted in Client_PresentCommercePurchaseUI

		--in Client_PresentMenuUI, we stuck the territory ID after BuyTank_.  Break it out and parse it to a number.
		local targetTerritoryID = tonumber(string.sub(order.Payload, 9));

		local targetTerritoryStanding = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID];

		if (targetTerritoryStanding.OwnerPlayerID ~= order.PlayerID) then
			return; --can only buy a tank onto a territory you control
		end

		
		if (order.CostOpt == nil) then
			return; --shouldn't ever happen, unless another mod interferes
		end

		local costFromOrder = order.CostOpt[WL.ResourceType.Gold]; --this is the cost from the order.  We can't trust this is accurate, as someone could hack their client and put whatever cost they want in there.  Therefore, we must calculate it ourselves, and only do the purchase if they match

		local realCost = Mod.Settings.CostToBuyTank;

		if (realCost > costFromOrder) then
			return; --don't do the purchase if their cost didn't line up.  This would only really happen if they hacked their client or another mod interfered
		end

		local numTanksAlreadyHave = 0;
		for _,ts in pairs(game.ServerGame.LatestTurnStanding.Territories) do
			if (ts.OwnerPlayerID == order.PlayerID) then
				numTanksAlreadyHave = numTanksAlreadyHave + NumTanksIn(ts.NumArmies);
			end
		end

		if (numTanksAlreadyHave >= Mod.Settings.MaxTanks) then
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'Skipping tank purchase since max is ' .. Mod.Settings.MaxTanks .. ' and you have ' .. numTanksAlreadyHave));
			return; --this player already has the maximum number of tanks possible, so skip adding a new one.
		end

		local tankPower = Mod.Settings.TankPower;

		local builder = WL.CustomSpecialUnitBuilder.Create(order.PlayerID);
		builder.Name = 'APC';
		builder.IncludeABeforeName = true;
		builder.ImageFilename = 'apc.png';
		builder.AttackPower = tankPower;
		builder.DefensePower = tankPower;
		builder.CombatOrder = 3415; --defends commanders
		builder.CanBeGiftedWithGiftCard = true;
		builder.CanBeTransferredToTeammate = true;
		builder.CanBeAirliftedToSelf = true;
		builder.CanBeAirliftedToTeammate = true;
		builder.IsVisibleToAllPlayers = true;
		builder.DamageToKill = tankPower;
		builder.DamageAbsorbedWhenAttacked = tankPower;

		local terrMod = WL.TerritoryModification.Create(targetTerritoryID);
		terrMod.AddSpecialUnits = {builder.Build()};

		local str = {};
		str[WL.StructureType.Attack] = 1;
		terrMod.SetStructuresOpt = str;
		
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'Purchased a tank', {}, {terrMod}));
	end
end

function NumTanksIn(armies)
	local ret = 0;
	for _,su in pairs(armies.SpecialUnits) do
		if (su.Name == 'Tank') then
			ret = ret + 1;
		end
	end
	return ret;
end
