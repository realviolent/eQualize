import unittest
from unittest.mock import MagicMock

# Mocking GSC environment
class Player:
    def __init__(self, name):
        self.Name = name
        self.pers = {"highKS": 0, "cur_kill_streak": 0}
        self.kills = 0
        self.deaths = 0
        self.kd = 0
        self.topkd = None

    def createFontString(self, font, scale):
        hud = MagicMock()
        hud.label = ""
        hud.value = None
        def setValue(val):
            hud.value = val
        hud.setValue = MagicMock(side_effect=setValue)
        return hud

    # Simulating the UpdateKD logic we expect in GSC
    def UpdateKD(self):
        kd = (self.kills / self.deaths) if self.deaths > 0 else self.kills
        self.kd = kd
        # In the optimized version, we expect this to update the HUD too
        if hasattr(self, 'topkd') and self.topkd:
             self.topkd.setValue(self.kd)

class Level:
    def __init__(self):
        self.players = []
        self.onPlayerKilled = None

level = Level()

# Simulating TopKS.gsc functions
def DisplayHighestKD(player):
    player.topkd = player.createFontString("small", 1)
    # Original code had a loop here.
    # optimized code will set initial value.
    if hasattr(player, 'kd'):
        player.topkd.setValue(player.kd)

def OnPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, lifeId, victim):
    # eAttacker logic from GSC
    if eAttacker.pers["cur_kill_streak"] > eAttacker.pers["highKS"]:
        eAttacker.pers["highKS"] = eAttacker.pers["cur_kill_streak"]

    # Update stats (simulated game engine behavior)
    eAttacker.kills += 1
    victim.deaths += 1

    # Call UpdateKD for both
    eAttacker.UpdateKD()
    victim.UpdateKD()

class TestTopKS(unittest.TestCase):
    def test_optimization_logic(self):
        p1 = Player("Player1")
        p2 = Player("Player2")
        level.players = [p1, p2]

        # 1. Player connects and HUD is initialized
        p1.kd = 0
        DisplayHighestKD(p1)

        self.assertIsNotNone(p1.topkd)
        p1.topkd.setValue.assert_called_with(0) # Initial set
        p1.topkd.setValue.reset_mock()

        # 2. Player 1 kills Player 2
        # Mocking the kill event
        OnPlayerKilled(None, p1, 100, "MOD_RIFLE", "m4", None, "head", 0, 0, 0, p2)

        # 3. Verify P1 HUD updated
        # P1: 1 kill, 0 deaths -> KD = 1
        self.assertEqual(p1.kills, 1)
        self.assertEqual(p1.deaths, 0)
        self.assertEqual(p1.kd, 1)
        p1.topkd.setValue.assert_called_with(1)

        # 4. Verify P2 HUD updated (if we were tracking it)
        # P2: 0 kills, 1 death -> KD = 0
        self.assertEqual(p2.kills, 0)
        self.assertEqual(p2.deaths, 1)
        self.assertEqual(p2.kd, 0)
        # Note: In current logic, P2's UpdateKD is called.
        # But P2 also needs DisplayHighestKD called to have topkd

if __name__ == '__main__':
    unittest.main()
