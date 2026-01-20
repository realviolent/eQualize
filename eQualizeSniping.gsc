#include maps\mp\gametypes\_hud_util;


init()
{
    print("loading eQualize Sniper Master");

    SetDvar("sv_enableDoubleTaps", 1);

    // Common Sniping Logic
    thread OnPlayerConnected();
    Advertising();

    level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::CodeCallback_PlayerDamage;

    // Mode Specific Logic (SND)
    if(getDvar("g_gametype") == "sd")
    {
        print("SND Mode Detected - Loading SND features");
        SetDvar("g_TeamName_Axis", "^4eQualize.");
        SetDvar("g_TeamName_Allies", "Others");

        SetDvar("g_TeamIcon_Allies", "iw5_cardicon_rampage");
        SetDvar("g_TeamIcon_Axis", "cardicon_sniper");

        level.AxisCount = 0;
        level.AlliesCount = 0;
        thread InitAliveHuds();
    }
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

// --- Alive / Team Count Logic (SND Specific) ---

InitAliveHuds()
{
    level.eQualizeText = level CreateServerFontString("small", 1);
    level.eQualizeText setPoint("TOPLEFT", "TOPLEFT", 0, 110);
    level.eQualizeText.label = &"^4eQualize: ^7";

    level.OthersText = level CreateServerFontString("small", 1);
    level.OthersText setPoint("TOPLEFT", "TOPLEFT", 0, 120);
    level.OthersText.label = &"^7Others: ^7";

    lastAxisCount = -1;
    lastAlliesCount = -1;

    while (true)
    {
        UpdateTeamCounts();

        if (level.AxisCount != lastAxisCount)
        {
            level.eQualizeText setValue(level.AxisCount);
            lastAxisCount = level.AxisCount;
        }

        if (level.AlliesCount != lastAlliesCount)
        {
            level.OthersText setValue(level.AlliesCount);
            lastAlliesCount = level.AlliesCount;
        }

        wait 0.5;
    }
}

UpdateTeamCounts()
{
    level.AxisCount = 0;
    level.AlliesCount = 0;

    foreach (player in level.players)
    {
        if (isDefined(player) && isAlive(player))
        {
            if (player.team == "axis")
                level.AxisCount++;
            else if (player.team == "allies")
                level.AlliesCount++;
        }
    }
}
