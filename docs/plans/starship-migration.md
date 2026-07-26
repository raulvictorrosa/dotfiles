# Migration plan: powerlevel10k → starship

> **Status: step 1 (starship swap) implemented** on
> `feat/starship-prompt-and-xdg-cleanup`. Step 2 (zinit → antidote) remains an
> outline only — a separate future PR, only if/when decided on later.

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

1. **Starship swap** (keep zinit) — done:
   - `brew install starship`.
   - Remove `zi ice depth=1; zi light romkatv/powerlevel10k` and the
     `[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh` line from `.zshrc`.
   - Add `eval "$(starship init zsh)"` — or, consistent with this branch's
     cached-eval-init pattern, wrap it in `_zsh_cached_eval_init starship
     init zsh` to avoid a fresh subprocess spawn every start.
   - Map the p10k segments actually in use (check `~/.p10k.zsh` for which
     `POWERLEVEL9K_LEFT/RIGHT_PROMPT_ELEMENTS` are enabled — likely dir, git
     status, exit code, command duration, context) to equivalent
     `starship.toml` modules (`directory`, `git_branch`/`git_status`,
     `cmd_duration`, `character` for exit-code coloring, etc.).
   - Side-by-side test: keep `~/.p10k.zsh` and the old prompt lines
     commented out (not deleted) for a week or two of daily driving before
     removing them for good.
   - Rollback: uncomment the p10k lines, comment out the starship line.

2. **zinit → antidote swap** (deferred — separate future PR, not part of this
   migration, only if/when decided on later):
   - `brew install antidote`.
   - Create `~/.zsh_plugins.txt` listing `zsh-users/zsh-autosuggestions`,
     `zsh-users/zsh-completions`, `zsh-users/zsh-syntax-highlighting`.
   - Replace the zinit self-bootstrap block + `zi light` lines with
     antidote's static-bundle load (`source <(antidote init)` /
     `antidote load` per current antidote docs — verify exact invocation
     against antidote's own docs at migration time, API may have moved on).
   - Remove the now-unused `~/.local/share/zinit` directory once confirmed
     working.
   - Rollback: antidote and zinit can coexist temporarily during testing
     (they don't conflict, they just both add functions to fpath) — no need
     to fully commit before verifying.

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

## Open questions

- ~~Benchmark starship's git-status rendering time~~ — resolved, see
  "Benchmark results" above.
- ~~Decide on a `starship.toml` preset~~ — resolved by shipping all 3
  candidates in `starship/.config/starship/` for a pre-merge pick:
  `starship-default.toml` (starship's own minimal defaults),
  `starship-tokyo-night.toml` (official preset), and
  `starship-pastel-powerline.toml` (official preset, closest segmented/diamond
  look to Powerlevel10k among starship's built-ins — currently the one wired
  up via `STARSHIP_CONFIG` in `.zshrc`). Swap the `STARSHIP_CONFIG` filename to
  compare; delete the two you don't want once decided.
