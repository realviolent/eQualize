
def simulate_monitor_hardscope_old(duration_seconds):
    timer1 = 10
    timer2 = 16

    cycle1 = 0
    cycle2 = 0

    current_time = 0.0
    elapsed_ticks = 0

    # We want to run for a fixed duration of "game time" or "monitoring time"?
    # The loop runs "forever". We want to measure how much "real time" elapses
    # for a given number of logical checks, OR how many logical checks happen in a fixed real time.
    # Let's say we want to monitor for 60 seconds of "intended" monitoring time.
    # In a perfect loop, that's 60 / 0.05 = 1200 iterations.

    iterations = 0
    max_iterations = int(duration_seconds / 0.05)

    print(f"Simulating {max_iterations} iterations (intended {duration_seconds}s)...")

    for _ in range(max_iterations):
        # User is ADS
        cycle1 += 1
        cycle2 += 1

        loop_duration = 0.05

        if cycle1 >= timer1:
            cycle1 = 0
            # AllowAds(false)
            loop_duration += 0.05 # extra wait

        if cycle2 >= timer2:
            cycle2 = 0
            # StunPlayer
            loop_duration += 0.05 # extra wait

        # End of loop wait
        current_time += loop_duration
        iterations += 1

    return current_time, iterations

def simulate_monitor_hardscope_new(duration_seconds):
    timer1 = 10
    timer2 = 16

    cycle1 = 0
    cycle2 = 0

    current_time = 0.0

    # New logic: single wait 0.05 at end.

    max_iterations = int(duration_seconds / 0.05)

    print(f"Simulating {max_iterations} iterations (intended {duration_seconds}s) with OPTIMIZATION...")

    for _ in range(max_iterations):
        cycle1 += 1
        cycle2 += 1

        if cycle1 >= timer1:
            cycle1 = 0
            # Action

        if cycle2 >= timer2:
            cycle2 = 0
            # Action

        current_time += 0.05

    return current_time

if __name__ == "__main__":
    duration = 60.0

    real_time_old, iterations = simulate_monitor_hardscope_old(duration)
    print(f"OLD Logic: {iterations} iterations took {real_time_old:.2f}s real time.")
    print(f"Drift: {real_time_old - duration:.2f}s")

    real_time_new = simulate_monitor_hardscope_new(duration)
    print(f"NEW Logic: {iterations} iterations took {real_time_new:.2f}s real time.")
    print(f"Drift: {real_time_new - duration:.2f}s")
