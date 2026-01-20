#include maps\mp\gametypes\_hud_util;

init()
{
    level.AxisCount = 0;
    level.AlliesCount = 0;

    thread InitHuds();
}

InitHuds()
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
