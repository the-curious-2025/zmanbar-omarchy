# ZmanBar for Omarchy

Puts the Hebrew date in your bar. Click it for the full date.


## Why this exists

There's a nice GNOME extension called [ZmanBar](https://github.com/Dev-in-the-BM/ZmanBar) that
does this for GNOME Shell. Omarchy doesn't run GNOME Shell — it's built on
[Quickshell](https://quickshell.org/) instead, a totally different QML-based framework — so
none of that code applies here. This is a from-scratch plugin for Omarchy's own bar-widget
system, built to do the same basic job.

## Install

```bash
git clone https://github.com/the-curious-2025/zmanbar-omarchy.git
cd zmanbar-omarchy
chmod +x install.sh
./install.sh
```

That drops the plugin into `~/.config/omarchy/plugins/zmanbar` and enables it in the center of
the bar. Didn't show up? Enable it by hand:

```bash
omarchy plugin enable zmanbar --section center
omarchy-restart-shell
```

## Using it

- **Click** the pill → Hebrew date + Gregorian date
- **Right-click** → switch between short (`ח׳ תשרי`) and full (`ח׳ תשרי תשפ״ז`) in the bar
- **Middle-click** → refresh

Day rolls over at local midnight.

## The Hebrew calendar math

Standard arithmetic Hebrew calendar (Dershowitz & Reingold). Tested against .NET's
`HebrewCalendar` across 20,000 random dates, 1900–2200 — no mismatches.

## Remove it

```bash
omarchy plugin disable zmanbar
rm -rf ~/.config/omarchy/plugins/zmanbar
```

## License

MIT. See [LICENSE](LICENSE).
