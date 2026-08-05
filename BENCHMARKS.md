# Shell startup benchmark

Measured on 2026-08-05 with ten fresh runs of `zsh -i -c exit` using `/usr/bin/time -p`.

| State | Runs | Warm mean | Minimum | Maximum |
|---|---:|---:|---:|---:|
| Before cleanup | 4 warm runs after first-run outlier | 0.495 s | 0.49 s | 0.50 s |
| After cleanup | 10 runs | 0.419 s | 0.39 s | 0.59 s |

The cleanup improved the measured warm mean by approximately 15%; eager NVM loading remains the dominant optional optimization opportunity.

The non-TTY benchmark emits Powerlevel10k monitor/gitstatus warnings because it runs an interactive shell without a terminal; ordinary Ghostty sessions were not observed to emit these warnings.
