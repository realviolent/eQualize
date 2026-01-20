#include maps\mp\gametypes\_hud_util;

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
