main()
{
    printLn("sd_nobombs::main called.");
    setDvarIfUninitialized( "sv_remove_bombsites", 0 );
    if (getDvarInt("sv_remove_bombsites") && getDvar("g_gametype") == "sd")
    {
        replacefunc(maps\mp\gametypes\_gameobjects::main, ::_gameobjects_main_custom);
    }
}
_gameobjects_main_custom(allowed)
{
    entitytypes = getentarray();
    for(i = 0; i < entitytypes.size; i++)
    {
        if(isdefined(entitytypes[i].script_gameobjectname))
        {
            // Only delete bomb related objects (bombzone, sd_bomb, etc)
            // This prevents deleting care packages (airdrop_pallet) which causes collision issues
            if (issubstr(entitytypes[i].script_gameobjectname, "bomb"))
            {
                entitytypes[i] delete();
            }
        }
    }
}
