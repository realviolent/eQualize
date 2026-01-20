#include maps\mp\gametypes\_hud_util;


init()
{
    print("loading eQualize Sniper");

    SetDvar("sv_enableDoubleTaps", 1);

    thread OnPlayerConnected();

    Advertising();

    level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::CodeCallback_PlayerDamage;
}

Advertising()
{
    shhhh = level createServerFontString( "Objective", 0.75 );
	shhhh setPoint( "RIGHT", "RIGHT", 0, -120 );
	shhhh setText("^4eQualize. ^7Sniping");
}

OnPlayerConnected()
{
    for (;;)
    {
        level waittill("connected", player);
		player thread OnPlayerSpawned();

		player thread eQualizeUtils::MonitorSniperWeapon();
		player thread eQualizeUtils::MonitorHardscope(10, 16);
	}
}

OnPlayerSpawned()
{
	self endon("disconnect");
	for (;;)
    {
        self waittill("changed_kit");
		if(isSubStr(self GetCurrentWeapon(), "usp") || eQualizeUtils::isSniper(self GetCurrentWeapon()) == false)
			eQualizeUtils::GiveIntervention();
	}
}


CodeCallback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
    if (eQualizeUtils::isSniper(sWeapon))
    {
		iDamage = 9999999;
    }
	else
	{
		iDamage = 0;
	}
	if (sMeansOfDeath == "MOD_FALLING")
	{
		self.health += iDamage;
	}

	if (isDefined(eAttacker))
	{
		if (isDefined(eAttacker.guid) && isDefined(self.guid))
		{
			if (eAttacker.guid == self.guid)
			{
				switch (sMeansOfDeath)
				{
					case "MOD_PROJECTILE_SPLASH": iDamage = 0;
					break;
					case "MOD_GRENADE_SPLASH": iDamage = 0;
					break;
					case "MOD_EXPLOSIVE": iDamage = 0;
					break;
					case "MOD_FALLING": iDamage = 0;
					break;
				}
			}
			else
			{
				if (sMeansOfDeath == "MOD_MELEE")
				{
					iDamage = 0;
				}
			}
		}
        [[level.OriginalCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
	}
}
