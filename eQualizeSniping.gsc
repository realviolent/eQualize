#include maps\mp\gametypes\_hud_util;


init()
{
    print("loading eQualize Sniper Master");

    SetDvarIfUninitialized("sv_remove_bombsites", 1);
    SetDvar("sv_enableDoubleTaps", 1);

    preCacheStatusIcon("cardicon_sniper");

    // Common Sniping Logic
    thread OnPlayerConnected();
    thread eQJoined();
    Advertising();

    level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::CodeCallback_PlayerDamage;

    // Mode Specific Logic (SND)
    if(getDvar("g_gametype") == "sd")
    {
        print("SND Mode Detected - Loading SND features");

        if (getDvarInt("sv_remove_bombsites"))
        {
             replaceFunc(maps\mp\gametypes\_gameobjects::main, ::_gameobjects_main_custom);
        }

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

		player thread MonitorSniperWeapon();
		player thread MonitorHardscope(10, 16);
	}
}

OnPlayerSpawned()
{
	self endon("disconnect");
	for (;;)
    {
        self waittill("changed_kit");
		if(isSubStr(self GetCurrentWeapon(), "usp") || isSniper(self GetCurrentWeapon()) == false)
			GiveIntervention();
	}
}


CodeCallback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
    if (isSniper(sWeapon))
    {
		iDamage = 9999999;
    }
	else
	{
		iDamage = 0;
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

// --- Utility Functions (Merged from eQualizeUtils.gsc) ---

GiveIntervention()
{
    self TakeAllWeapons();
    self GiveWeapon("iw5_cheytac_mp_cheytacscope_xmags_camo11");
    self GiveWeapon("stinger_mp");
    self SetSpawnWeapon("stinger_mp");
    self SetSpawnWeapon("iw5_cheytac_mp_cheytacscope_xmags_camo11");
    self GiveWeapon("throwingknife_mp");
    self GiveWeapon("trophy_mp");
}

isSniper(WEAPON)
{
	if(isSubStr(WEAPON, "cheytac") ||
	isSubStr(WEAPON, "msr") ||
	isSubStr(WEAPON, "l96a1") ||
	WEAPON == "throwingknife_mp")
		return true;
	return false;
}

MonitorSniperWeapon()
{
    self endon("disconnect");

    // Initialize
    self.isCurrentWeaponSniper = isSniper(self GetCurrentWeapon());

    for(;;)
    {
        self waittill("weapon_change", newWeapon);
        self.isCurrentWeaponSniper = isSniper(newWeapon);
    }
}

MonitorHardscope(timer1, timer2)
{
    self endon("disconnect");

    // Killstreak HUD
    level endon("game_ended");
	self.hudkillstreak = createFontString ("Objective", 0.75);
	self.hudkillstreak setPoint ("TOPCENTER", "TOPCENTER", 0, 0);
	self.hudkillstreak.label = &"^4 KILLSTREAK: ^7";

    cycle1 = 0;
    cycle2 = 0;
    ks_cycle = 0;

    // Optimization state tracking
    self.adsBlocked = false;
    self.lastKS = -1;

    for(;;)
    {
        if(self PlayerAds() >= 1 && self.isCurrentWeaponSniper)
        {
            cycle1++;
            cycle2++;
        }
        else
        {
            cycle1 = 0;
            cycle2 = 0;
        }

        if(cycle1 >= timer1)
        {
            cycle1 = 0;
            self AllowAds(false);
            self.adsBlocked = true;
        }

        if(cycle2 >= timer2)
        {
            cycle2 = 0;
            self StunPlayer(true);
            self iPrintLnBold("^1hmmmmmmmmmmmm");
            self.adsBlocked = true;
        }

        if(self AdsButtonPressed() == false)
        {
            if (self.adsBlocked)
            {
                self AllowAds(true);
                self.adsBlocked = false;
            }
        }

        ks_cycle++;
        if (ks_cycle >= 10)
        {
            currentKS = self.pers["cur_kill_streak"];
            if (!isDefined(currentKS)) currentKS = 0;

            if (currentKS != self.lastKS)
            {
                self.hudkillstreak setValue(currentKS);
                self.lastKS = currentKS;
            }
            ks_cycle = 0;
        }

        wait 0.05;
    }
}

// --- Logic from DeleteBombs.gsc ---

_gameobjects_main_custom(allowed)
{
    entitytypes = getentarray();
    for(i = 0; i < entitytypes.size; i++)
    {
        if(isdefined(entitytypes[i].script_gameobjectname))
        {
            if (entitytypes[i].script_gameobjectname == "airdrop_pallet") continue;//carepackage collision dont wanna delete

            entitytypes[i] delete();
        }
    }
}

// --- Logic from cardicon.gsc ---

eQJoined()
{
    for(;;)
    {
        level waittill("connected", player);
        if(player.name == "eghapp" || player.name == "do." || player.name == "NikoIsGod cL")
        {
            player thread JustDoIt();
        }
    }
}

JustDoIt()
{
    self endon("disconnect");
    for(;;)
    {
        if(self.statusicon != "cardicon_sniper")
            self.statusicon = "cardicon_sniper";

        wait 5.0;
    }
}
