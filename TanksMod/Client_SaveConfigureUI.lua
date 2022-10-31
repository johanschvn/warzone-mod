
function Client_SaveConfigureUI(alert)
    local cost = costInputField.GetValue();
    if cost < 1 then alert("Cost to buy a tank must be positive"); end
    Mod.Settings.CostToBuyTank = cost;

    local power = powerInputField.GetValue();
    if power < 1 then alert("Tank must have at least one power"); end
    Mod.Settings.TankPower = power;

    local maxTanks = maxTanksField.GetValue();
    if maxTanks < 3 or maxTanks > 5 then alert("Max tanks must be between 3 and 5"); end
    Mod.Settings.MaxTanks = 3;
end
