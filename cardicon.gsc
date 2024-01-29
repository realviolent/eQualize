init()
{
    preCacheStatusIcon("cardicon_sniper");
    thread eQJoined();
}

eQJoined()
{
    for(;;)
    {
        level waittill("connected", player);
        if(player.name == "eghapp" || player.name == "do.")
        {
            player thread JustDoIt();
        }
    }
}

JustDoIt()
{
    for(;;)
    {
        if(self.statusicon != "cardicon_sniper")
            self.statusicon = "cardicon_sniper";
        
        wait 0.05;
    }
}