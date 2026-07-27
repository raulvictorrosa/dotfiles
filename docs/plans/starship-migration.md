# Migration plan: powerlevel10k → starship

> **Status: both steps implemented** on `feat/starship-prompt-and-xdg-cleanup`.
> Step 1 (starship swap) and step 2 (zinit → antidote) were done in the same
> PR after all — the original "sequence these separately" caution turned out
> not to matter in practice; see "Antidote results" below. Powerlevel10k has
> since been fully removed (no more commented-out rollback lines).

## Why consider this at all

Powerlevel10k is fast *for a zsh-script prompt* — it uses `gitstatusd` (a
background daemon written in C++) to avoid shelling out to `git` on every
prompt render, and ships a "classic" instant-prompt mechanism to paint a
prompt before the rest of `.zshrc` has even finished. But it's still:

- a ~1700-line zsh script (`~/.p10k.zsh`) sourced and interpreted in-process
  on every shell start,
- coupled to zsh specifically — the config and rendering logic are zsh
  functions, not a portable format,
- one more thing `zinit` has to clone/compile/manage.

**Starship** is a single precompiled Rust binary. There's no interpreter
overhead: `starship init zsh` just wires a `precmd`/`preexec` hook that shells
out to the `starship` binary, which reads a `starship.toml` (a portable,
non-zsh-specific format — same config could drive bash/fish/nushell prompts
if that ever mattered) and prints the prompt string directly. No zsh script
parsing, no gitstatusd process to manage separately, no per-shell `.p10k.zsh`
compile step.

The tradeoff: starship still shells out to `git` for repo status by default
(no bundled gitstatusd-equivalent), so on very large repos p10k's async
gitstatusd can out-perform starship's git calls unless starship's own git
status caching/async settings are tuned. Worth benchmarking on this machine's
actual repos before committing to the swap, not just trusting general
reputation.

## Plugin manager: zinit vs antidote

Once oh-my-zsh + powerlevel10k are dropped, something still needs to manage
`zsh-autosuggestions`, `zsh-completions`, and `zsh-syntax-highlighting` — a
prompt engine alone doesn't replace a plugin manager.

| | `zinit` (current) | `antidote` |
|---|---|---|
| **Model** | Feature-rich: turbo mode (`wait`/`lucid` ice), ice-modifier DSL, annexes (as-monitor, bin-gem-node, patch-dl, rust), plugin/snippet management, self-update | Minimal: bundle a plugin list, `antidote bundle` compiles it into a single static `.zsh` file that's just `source`d — no per-plugin logic at shell start |
| **Startup cost** | Turbo mode gets close to zero blocking cost for deferred plugins, but the manager itself (parsing ice mods, annex machinery) has more moving parts to load first | Startup cost is close to a single `source` of a pre-built static file — very little to interpret at runtime since the "decision making" happened at `antidote bundle` time, not shell-start time |
| **OMZ plugin compatibility** | Full — this repo already leans on OMZ-style plugin loading conventions | Full — antidote is explicitly designed around loading oh-my-zsh and non-OMZ plugins interchangeably via its bundle file syntax |
| **Config complexity** | Higher — ice modifiers (`wait`, `lucid`, `depth`, `blockf`, etc.) are powerful but have a learning curve; this branch's investigation already hit one non-obvious behavior (turbo-loaded plugins queuing `compdef` calls that trigger a second, separate `compinit` on first plugin install) | Lower — a `.zsh_plugins.txt` list plus one `antidote bundle` command; less surface area for surprising interactions |
| **Maintenance activity** | Actively maintained (zdharma-continuum fork, community-run after original zdharma repo went dark) | Actively maintained by Mattias Slabanja (getantidote/antidote), smaller but focused scope |
| **Already in use here** | Yes — this repo already has a working zinit setup post-cleanup | No — would be a net-new tool to adopt |

### Recommendation

Lean **antidote** for a starship-paired setup, specifically *because* the job
shrinks once oh-my-zsh is gone: with p10k's `zi ice depth=1; zi light
romkatv/powerlevel10k` line gone and no more OMZ-plugin-shaped turbo
juggling, all zinit is left doing is loading three completion/suggestion
plugins — a job antidote's static-bundle model does with less runtime
machinery and less surface area for the kind of second-compinit surprise
this branch had to debug around. zinit's turbo mode earns its complexity
when you're loading many plugins with fine-grained async control; three
plugins with a prompt that's no longer zinit-managed doesn't need that.

Counter-consideration: switching plugin managers *and* prompt engines in the
same migration compounds what could go wrong and makes rollback harder to
reason about. A safer sequencing is: switch to starship first (keep zinit
managing the same three plugins, drop only the `powerlevel10k` line), verify
that's solid, *then* separately evaluate swapping zinit → antidote once
starship is proven out. Treat this as two smaller migrations, not one.

## Migration steps

1. **Starship swap** (keep zinit initially) — done:
   - `brew install starship`.
   - Added `_zsh_cached_eval_init starship init zsh` (reusing this branch's
     existing cached-eval-init pattern to avoid a fresh subprocess spawn every
     start).
   - Side-by-side tested p10k vs. starship live in the same session (briefly
     re-enabled p10k's instant-prompt + `zi light romkatv/powerlevel10k` +
     `~/.p10k.zsh` source, uncommitted, purely for comparison) before
     deciding: starship (default preset — not a segmented/powerline preset;
     none of starship's built-ins fully replicate p10k's two-line layout) won.
   - Powerlevel10k fully removed from `.zshrc` — no rollback lines kept. If
     ever wanted back: `zi ice depth=1; zi light romkatv/powerlevel10k`, plus
     sourcing `~/.p10k.zsh` (still present on disk, untouched, not managed by
     this repo) and its instant-prompt cache block — see git history on this
     branch (pre-removal commit) for the exact lines.

2. **zinit → antidote swap** — done, same PR (see "Antidote results" below
   for why the original "sequence these separately" caution didn't end up
   mattering):
   - `brew install antidote`.
   - `zsh/.zsh_plugins.txt` lists `zsh-users/zsh-autosuggestions`,
     `zsh-users/zsh-completions`, `zsh-users/zsh-syntax-highlighting`.
   - Replaced the zinit self-bootstrap block + `zi light` lines with:

     ```sh
     source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
     antidote load
     ```

     (current antidote docs, confirmed against antidote.sh at migration
     time — `antidote load` auto-discovers `${ZDOTDIR:-$HOME}/.zsh_plugins.txt`,
     clones plugins on first run, and generates/caches a static
     `~/.zsh_plugins.zsh` that's just sourced afterward.)
   - `~/.local/share/zinit` (30M) left on disk for now, not yet deleted —
     harmless leftover, delete once fully confident nothing else references
     it.

## Antidote results

The user's subjective impression during side-by-side comparison was "p10k
feels faster than starship" — worth separating two different variables
(prompt engine vs. plugin manager) instead of conflating them. Measured full
interactive-shell cold-start time (`hyperfine --warmup 5 --min-runs 15 'zsh -i
-c exit'`, warm caches, 2026-07-27) across three variants, each restored from
git history into an isolated `ZDOTDIR` so the comparison is apples-to-apples
on the same machine, same moment:

| Variant | Mean | Min | Max |
|---|---|---|---|
| Original: p10k + zinit (pre-migration) | 262.8 ms ± 42.2 ms | 220.8 ms | 397.9 ms |
| starship + zinit (mid-migration) | 266.3 ms ± 51.4 ms | 229.9 ms | 422.8 ms |
| starship + antidote (current) | 269.1 ms ± 64.3 ms | 209.1 ms | 426.4 ms |

**No measurable difference between any of the three** — well within each
other's noise band. Conclusion: the perceived "p10k is faster" is almost
certainly p10k's *instant-prompt* trick (paints a cached prompt string
immediately, before the rest of `.zshrc` actually finishes executing) — a
perceived-latency illusion, not a real wall-clock difference. Starship has no
equivalent trick, so even at identical real cost it can *feel* slightly
behind. zinit → antidote also produced no measurable startup-time gain on
this machine, likely because this setup only ever had 3 lightweight
turbo-loaded plugins — not enough plugin-manager overhead for antidote's
simpler static-bundle model to show a difference. Antidote was kept anyway
per the original recommendation's non-performance rationale (less runtime
machinery, smaller surface area, one less second-`compinit` class of
surprise) — not because it's faster.

## Benchmark results

Measured with `hyperfine --warmup 3 --min-runs 20 'starship prompt'` (2026-07-26,
`starship` 1.26.0, pastel-powerline preset active via `STARSHIP_CONFIG`), run
directly inside each repo:

| Repo | Dirty files | Mean | Min | Max | Runs |
|---|---|---|---|---|---|
| `diy.web.frontend` | 3 | 79.7 ms ± 59.2 ms | 28.9 ms | 334.7 ms | 60 |
| `opacc.web.app` | 8 | 54.6 ms ± 42.8 ms | 28.7 ms | 262.7 ms | 35 |

`hyperfine` flagged statistical outliers on both runs (background system load
during measurement, not something inherent to starship) — the **min** column
(~29 ms) is the more representative floor for what starship actually costs to
shell out to `git` on these repos; the wide max/σ is noise from other
processes on the machine, not a git-status-scaling problem. At prompt-draw
time, high-20ms is imperceptible — confirms the swap is safe to proceed with
on this machine's real repos, not just in general. If it's ever perceived as
laggy in practice, starship's `git_status`/`git_metrics` modules have
their own disable/timeout knobs to revisit.

**Scope note**: this only measures `starship prompt`'s own render cost on a
warm binary/warm disk cache — it does *not* measure full cold-shell-startup
time (oh-my-zsh sourcing, zinit's turbo re-eval, `compinit`, etc.). Separately
observed: opening several new terminals back-to-back is fast, but a shell
opened after ~1h idle takes a few seconds — that's a distinct, already-known
intermittent slow-startup issue (pre-dates this migration, previously
profiled with `zprof` inconclusively since it wasn't reproducible on demand)
and is unrelated to starship specifically. Next time it's caught live,
profile that cold shell directly with `zprof` rather than assuming starship
is the cause — this benchmark doesn't rule it in or out either way.

## Open questions

- ~~Benchmark starship's git-status rendering time~~ — resolved, see
  "Benchmark results" above.
- ~~Decide on a `starship.toml` preset~~ — resolved after live comparison:
  **`starship-default.toml`** (starship's own minimal defaults, no preset)
  is the one wired up via `STARSHIP_CONFIG` in `.zshrc`. `starship-tokyo-night.toml`
  and `starship-pastel-powerline.toml` are left committed in
  `starship/.config/starship/` as reference/fallback options — delete them
  whenever, not blocking.
