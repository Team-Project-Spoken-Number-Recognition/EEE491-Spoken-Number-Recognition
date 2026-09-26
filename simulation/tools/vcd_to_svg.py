"""vcd_to_svg.py — render digital waveforms from a VCD file as a stand-alone SVG image.

Pure Python standard library (no matplotlib). Used for report / demo figures of every lab:
XSim writes the VCD (Tcl: open_vcd / log_vcd / run / close_vcd), this module draws it.

    from vcd_to_svg import Vcd, render
    vcd = Vcd("debug_waves.vcd")
    render(vcd, [("tb.clk", "clock_in", "clock"), ("tb.txd", "txd_out", "bit"),
                 ("tb.rx_byte", "UART byte", "bus")],
           t0_ns=0, t1_ns=2000, out="fig.svg", title="...", caption="...",
           markers=[(200, "start sampled")], notes=[(250, "txd_out", "start bit")])

Signal kinds: "clock" (square wave; drawn as a band if too dense), "bit" (0/1, X/Z grey),
"bus" (hex value boxes). Names are dotted VCD paths (scope.scope.signal).

Author : Eren (eeerenbuyukbas) — AI-assisted (Claude Opus 5.5, Claude Code), AI-0013
"""
import bisect
import html

FS_PER = {"s": 10**15, "ms": 10**12, "us": 10**9, "ns": 10**6, "ps": 10**3, "fs": 1}


class Vcd:
    """Minimal VCD reader: scalar and vector wires, one timescale."""

    def __init__(self, path):
        self.fs_per_unit = 1000          # default 1 ps
        self.ids = {}                    # id -> [full names]
        self.width = {}                  # full name -> bits
        self.times = {}                  # id -> [time_fs]
        self.values = {}                 # id -> [value str]
        scope = []
        t = 0
        with open(path, encoding="utf-8", errors="replace") as f:
            text = f.read()
        tokens = iter(text.split())
        for tok in tokens:
            if tok == "$timescale":
                spec = []
                for x in tokens:
                    if x == "$end":
                        break
                    spec.append(x)
                s = "".join(spec)
                num = int("".join(c for c in s if c.isdigit()) or 1)
                unit = "".join(c for c in s if c.isalpha())
                self.fs_per_unit = num * FS_PER[unit]
            elif tok == "$scope":
                next(tokens)
                scope.append(next(tokens))
                next(tokens)                               # $end
            elif tok == "$upscope":
                scope.pop()
                next(tokens)
            elif tok == "$var":
                _kind, width, ident, name = next(tokens), int(next(tokens)), next(tokens), next(tokens)
                x = next(tokens)
                while x != "$end":                         # optional [msb:lsb]
                    x = next(tokens)
                full = ".".join(scope + [name])
                self.ids.setdefault(ident, []).append(full)
                self.width[full] = width
                self.times.setdefault(ident, [])
                self.values.setdefault(ident, [])
            elif tok.startswith("$"):
                if tok in ("$dumpvars", "$dumpall", "$dumpon", "$dumpoff", "$end"):
                    continue
                for x in tokens:                           # skip other sections
                    if x == "$end":
                        break
            elif tok[0] == "#":
                t = int(tok[1:]) * self.fs_per_unit
            elif tok[0] in "bB":
                val, ident = tok[1:], next(tokens)
                self._add(ident, t, val)
            elif tok[0] in "01xXzZuU-":
                self._add(tok[1:], t, tok[0])
        self.by_name = {n: i for i, names in self.ids.items() for n in names}

    def _add(self, ident, t, val):
        ts, vs = self.times[ident], self.values[ident]
        if ts and ts[-1] == t:
            vs[-1] = val
        else:
            ts.append(t)
            vs.append(val)

    def names(self):
        return sorted(self.by_name)

    def series(self, name):
        i = self.by_name[name]
        return self.times[i], self.values[i]

    def value_at(self, name, t_fs):
        ts, vs = self.series(name)
        k = bisect.bisect_right(ts, t_fs) - 1
        return vs[k] if k >= 0 else "x"

    def edges(self, name, to=None):
        """times (ns) where the signal changes (to a given value if `to` is set)"""
        ts, vs = self.series(name)
        out = []
        for k in range(1, len(ts)):
            if vs[k] != vs[k - 1] and (to is None or vs[k] == to):
                out.append(ts[k] / 1e6)
        return out


def _hex(val, width):
    if any(c in "xXzZuU" for c in val):
        return "X"
    n = int(val, 2)
    digits = max(1, (width + 3) // 4)
    return format(n, "0%dX" % digits)


def render(vcd, signals, t0_ns, t1_ns, out, title="", caption="", markers=(), notes=(),
           width=1400, row_h=38, label_w=170):
    """Write an SVG with one row per signal between t0_ns and t1_ns."""
    t0_ns = max(0.0, t0_ns)                                # no time before the simulation start
    t0, t1 = t0_ns * 1e6, t1_ns * 1e6                      # fs
    plot_w = width - label_w - 30
    top = (58 if title else 20) + (14 if markers else 0)
    height = top + row_h * len(signals) + 70 + (22 if caption else 0)

    def x(t_fs):
        return label_w + (t_fs - t0) / (t1 - t0) * plot_w

    s = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" '
         'font-family="Consolas, Menlo, monospace" font-size="13">' % (width, height),
         '<rect width="100%" height="100%" fill="white"/>']
    if title:
        s.append('<text x="12" y="26" font-size="17" font-weight="bold" '
                 'font-family="Segoe UI, Arial, sans-serif">%s</text>' % html.escape(title))

    # time grid
    span_ns = t1_ns - t0_ns
    step = next(st for st in (1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000)
                if span_ns / st <= 14)
    unit, div = ("us", 1000.0) if span_ns >= 5000 else ("ns", 1.0)
    g = (int(t0_ns // step) + 1) * step
    ybot = top + row_h * len(signals)
    while g < t1_ns:
        gx = x(g * 1e6)
        s.append('<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="#e4e4e4"/>' % (gx, top - 6, gx, ybot))
        lab = ("%g" % (g / div)) + " " + unit
        s.append('<text x="%.1f" y="%d" text-anchor="middle" fill="#666" font-size="11">%s</text>'
                 % (gx, ybot + 16, lab))
        g += step

    for r, (name, label, kind) in enumerate(signals):
        y0 = top + r * row_h
        hi, lo, mid = y0 + 8, y0 + row_h - 10, y0 + row_h / 2 - 1
        s.append('<text x="%d" y="%.1f" text-anchor="end" fill="#222">%s</text>'
                 % (label_w - 12, mid + 4, html.escape(label)))
        s.append('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="#f0f0f0"/>'
                 % (label_w, y0 + row_h - 2, width - 20, y0 + row_h - 2))
        ts, vs = vcd.series(name)
        k = bisect.bisect_right(ts, t0) - 1                 # last change at or before t0 (-1: none)
        segs = []                                           # (t_start, t_end, value)
        cur_t, cur_v = t0, (vs[k] if k >= 0 else "x")
        for j in range(k + 1, len(ts)):
            if ts[j] >= t1:
                break
            if ts[j] > t0:
                segs.append((cur_t, ts[j], cur_v))
                cur_t = ts[j]
            cur_v = vs[j]
        segs.append((cur_t, t1, cur_v))
        color = "#1f5fbf" if kind != "clock" else "#555"

        if kind == "clock" and len(segs) > plot_w / 3:
            s.append('<rect x="%d" y="%d" width="%d" height="%d" fill="#ddd"/>'
                     % (label_w, hi, plot_w, lo - hi))
            s.append('<text x="%.1f" y="%.1f" text-anchor="middle" fill="#555" font-size="11">'
                     '100 MHz clock (too dense to draw)</text>' % (label_w + plot_w / 2, mid + 4))
        elif kind in ("bit", "clock"):
            pts, prev_y = [], None
            for (a, b, v) in segs:
                if v in "1":
                    yy = hi
                elif v in "0":
                    yy = lo
                else:
                    s.append('<rect x="%.1f" y="%d" width="%.1f" height="%d" fill="#fbe3e3"/>'
                             % (x(a), hi, max(0.5, x(b) - x(a)), lo - hi))
                    yy = mid
                if prev_y is not None and prev_y != yy:
                    pts.append((x(a), prev_y))
                pts.append((x(a), yy))
                pts.append((x(b), yy))
                prev_y = yy
            s.append('<polyline fill="none" stroke="%s" stroke-width="1.6" points="%s"/>'
                     % (color, " ".join("%.1f,%.1f" % p for p in pts)))
        else:                                               # bus
            w = vcd.width[name]
            for (a, b, v) in segs:
                xa, xb = x(a), x(b)
                sl = min(4, (xb - xa) / 2)
                fill = "#eef3fb" if "X" not in _hex(v, w) else "#fbe3e3"
                s.append('<polygon points="%.1f,%.1f %.1f,%d %.1f,%d %.1f,%.1f %.1f,%d %.1f,%d" '
                         'fill="%s" stroke="%s" stroke-width="1.2"/>'
                         % (xa, mid, xa + sl, hi, xb - sl, hi, xb, mid, xb - sl, lo, xa + sl, lo,
                            fill, color))
                txt = _hex(v, w)
                if xb - xa > 9 * len(txt) + 6:
                    s.append('<text x="%.1f" y="%.1f" text-anchor="middle" fill="#123">%s</text>'
                             % ((xa + xb) / 2, mid + 4.5, txt))

    placed = []                                             # (x, level) of marker labels
    for (t_ns, text) in sorted(markers):
        mx = x(t_ns * 1e6)
        level = 0                                           # stagger labels that would overlap
        while any(abs(mx - px) < 7 * max(len(text), 12) and pl == level for px, pl in placed):
            level += 1
        placed.append((mx, level))
        ly = top - 12 - 13 * level
        s.append('<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="#d14" stroke-dasharray="4,3"/>'
                 % (mx, ly + 2, mx, ybot))
        right = mx > label_w + plot_w * 0.8                 # keep labels inside the image
        s.append('<text x="%.1f" y="%d" fill="#d14" font-size="11" text-anchor="%s">%s</text>'
                 % (mx - 3 if right else mx + 3, ly, "end" if right else "start", html.escape(text)))

    row_of = {label: r for r, (_n, label, _k) in enumerate(signals)}
    for (t_ns, label, text) in notes:
        r = row_of[label]
        s.append('<text x="%.1f" y="%d" fill="#b35900" font-size="11" text-anchor="middle">%s</text>'
                 % (x(t_ns * 1e6), top + r * row_h + 6, html.escape(text)))

    if caption:
        s.append('<text x="12" y="%d" fill="#333" font-size="12" '
                 'font-family="Segoe UI, Arial, sans-serif">%s</text>' % (height - 14, html.escape(caption)))
    s.append("</svg>")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(s))
    return out
