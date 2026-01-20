
import time

def simulate_monitor_hardscope_current(duration_seconds):
    timer1 = 10
    timer2 = 16

    cycle1 = 0
    cycle2 = 0
    ks_cycle = 0

    current_time = 0.0
    engine_calls = 0

    max_iterations = int(duration_seconds / 0.05)

    # Assume player is NOT ADS initially, then ADS for some time, then NOT.
    # To simulate worst case for "current" logic regarding AllowAds(true),
    # we assume player is NOT ADS, so AdsButtonPressed() is false.
    # In current logic, if !AdsButtonPressed(), we call AllowAds(true).

    print(f"Simulating {max_iterations} iterations (intended {duration_seconds}s) with CURRENT logic...")

    start_real = time.time()

    for i in range(max_iterations):
        # Simulation: Player is NOT ADS
        is_ads = False

        if is_ads:
            cycle1 += 1
            cycle2 += 1
        else:
            cycle1 = 0
            cycle2 = 0

        if cycle1 >= timer1:
            cycle1 = 0
            # AllowAds(false)
            engine_calls += 1

        if cycle2 >= timer2:
            cycle2 = 0
            # StunPlayer
            engine_calls += 1

        # Current Logic:
        if not is_ads:
            # AllowAds(true) is called every frame
            engine_calls += 1

        ks_cycle += 1
        if ks_cycle >= 10:
            # hudkillstreak setValue() called every 10 ticks
            # Even if value hasn't changed
            engine_calls += 1
            ks_cycle = 0

        current_time += 0.05

    end_real = time.time()
    return end_real - start_real, engine_calls

def simulate_monitor_hardscope_optimized(duration_seconds):
    timer1 = 10
    timer2 = 16

    cycle1 = 0
    cycle2 = 0
    ks_cycle = 0

    ads_blocked = False
    last_ks = -1
    cur_ks = 5 # Simulation value

    current_time = 0.0
    engine_calls = 0

    max_iterations = int(duration_seconds / 0.05)

    print(f"Simulating {max_iterations} iterations (intended {duration_seconds}s) with OPTIMIZED logic...")

    start_real = time.time()

    for i in range(max_iterations):
        # Simulation: Player is NOT ADS
        is_ads = False

        if is_ads:
            cycle1 += 1
            cycle2 += 1
        else:
            cycle1 = 0
            cycle2 = 0

        if cycle1 >= timer1:
            cycle1 = 0
            # AllowAds(false)
            engine_calls += 1
            ads_blocked = True

        if cycle2 >= timer2:
            cycle2 = 0
            # StunPlayer
            engine_calls += 1

        # Optimized Logic:
        if not is_ads:
            if ads_blocked:
                # AllowAds(true)
                engine_calls += 1
                ads_blocked = False

        ks_cycle += 1
        if ks_cycle >= 10:
            # Check if value changed
            if cur_ks != last_ks:
                # hudkillstreak setValue()
                engine_calls += 1
                last_ks = cur_ks
            ks_cycle = 0

        current_time += 0.05

    end_real = time.time()
    return end_real - start_real, engine_calls

if __name__ == "__main__":
    duration = 60.0

    real_time_curr, calls_curr = simulate_monitor_hardscope_current(duration)
    print(f"CURRENT Logic: {calls_curr} engine calls.")

    real_time_opt, calls_opt = simulate_monitor_hardscope_optimized(duration)
    print(f"OPTIMIZED Logic: {calls_opt} engine calls.")

    diff = calls_curr - calls_opt
    print(f"Reduction: {diff} calls ({diff/calls_curr*100:.1f}%)")
