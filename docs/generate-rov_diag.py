#!/usr/bin/env python3
"""
Generate rovibe workflow diagram SVG with embedded JetBrains Mono font.

Usage:
    python3 generate-rovibe-diagram.py \
        --regular JetBrainsMono-Regular.ttf \
        --bold    JetBrainsMono-Bold.ttf \
        --output  rovibe-diagram.svg
"""

import argparse
import base64

def load_font(path):
    with open(path, 'rb') as f:
        return base64.b64encode(f.read()).decode('ascii')

def generate(reg_b64, bold_b64):
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="860" height="440" viewBox="0 0 860 440">
<defs>
  <style>
    @font-face {{
      font-family: 'JB';
      font-weight: 400;
      src: url('data:font/ttf;base64,{reg_b64}') format('truetype');
    }}
    @font-face {{
      font-family: 'JB';
      font-weight: 700;
      src: url('data:font/ttf;base64,{bold_b64}') format('truetype');
    }}
    text {{ font-family: 'JB', monospace; }}
  </style>
</defs>

<!-- background -->
<rect width="860" height="440" fill="#000000"/>

<!-- TITLE (centered) -->
<text x="430" y="52" font-size="26" font-weight="700" fill="#ffffff" text-anchor="middle">rovibe</text>
<!--
<text x="430" y="52" font-size="10" fill="#808080" letter-spacing="2.5" text-anchor="middle">AGENT ISOLATION OVERVIEW</text>
-->

<g transform="translate(0, 48)">
<!-- COLUMN HEADERS -->
<text x="200" y="74" font-size="9" fill="#9f9fcf" letter-spacing="2" text-anchor="middle">OPERATOR</text>
<text x="498" y="74" font-size="9" fill="#9cdcfe" letter-spacing="2" text-anchor="middle">ISOLATION LAYER</text>
<text x="728" y="74" font-size="9" fill="#87ffff" letter-spacing="2" text-anchor="middle">AGENT</text>

<!-- TOP RULE -->
<!--
<line x1="40" y1="80" x2="820" y2="80" stroke="#1e1e1e" stroke-width="1"/>
-->

<!-- VERTICAL COLUMN DIVIDERS (stop before footer) -->
<!--
<line x1="374" y1="80" x2="374" y2="348" stroke="#1e1e1e" stroke-width="1"/>
<line x1="622" y1="80" x2="622" y2="348" stroke="#1e1e1e" stroke-width="1"/>
-->

<!-- ROW 1 -->
<rect x="40" y="90" width="320" height="72" fill="#0d0b14" stroke="#3a3060" stroke-width="1"/>
<text x="200" y="104" font-size="8" fill="#9f9fcf" letter-spacing="1.5" text-anchor="middle">CREATE AGENT</text>
<text x="200" y="120" font-size="10" font-weight="700" fill="#d0d0d0" text-anchor="middle">rovibe create &lt;agent&gt;</text>
<text x="200" y="136" font-size="9" fill="#9f9fcf" text-anchor="middle">rovibe create a.noir</text>
<text x="200" y="152" font-size="8.5" fill="#585858" text-anchor="middle">provision a.noir, add to agents, create apparmor profile</text>

<line x1="360" y1="126" x2="380" y2="126" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="380,122 388,126 380,130" fill="#3a3a3a"/>

<rect x="388" y="90" width="220" height="72" fill="#080c14" stroke="#2a4060" stroke-width="1"/>
<text x="498" y="107" font-size="8" fill="#9cdcfe" letter-spacing="1.5" text-anchor="middle">IDENTITY</text>
<text x="498" y="124" font-size="12" font-weight="700" fill="#d0d0d0" text-anchor="middle">/home/a.noir/</text>
<text x="498" y="141" font-size="10" fill="#9cdcfe" text-anchor="middle">uid restricted · gid: agents</text>
<text x="498" y="155" font-size="8.5" fill="#585858" text-anchor="middle">PATH=/opt/rovibe/a.noir/bin  [readonly]</text>

<line x1="608" y1="126" x2="628" y2="126" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="628,122 636,126 628,130" fill="#3a3a3a"/>

<rect x="636" y="90" width="184" height="72" fill="#140808" stroke="#5a1a1a" stroke-width="1"/>
<text x="728" y="107" font-size="8" fill="#ff5f5f" letter-spacing="1.5" text-anchor="middle">BLOCKED · CANNOT</text>
<text x="728" y="124" font-size="11" font-weight="700" fill="#d0d0d0" text-anchor="middle">write source tree</text>
<text x="728" y="141" font-size="9.5" fill="#cc4444" text-anchor="middle">git commit · git push</text>
<text x="728" y="155" font-size="8.5" fill="#585858" text-anchor="middle">install pkgs · escalate privs</text>

<!-- ROW 2 -->
<rect x="40" y="174" width="320" height="72" fill="#0d0b14" stroke="#3a3060" stroke-width="1"/>
<text x="200" y="188" font-size="8" fill="#9f9fcf" letter-spacing="1.5" text-anchor="middle">ASSIGN TO PROJECT</text>
<text x="200" y="204" font-size="10" font-weight="700" fill="#d0d0d0" text-anchor="middle">rovibe assign &lt;agent&gt; &lt;project&gt; --role &lt;role&gt;</text>
<text x="200" y="220" font-size="9" fill="#9f9fcf" text-anchor="middle">rovibe assign a.noir ~/repos/project --role reviewer</text>
<text x="200" y="236" font-size="8.5" fill="#585858" text-anchor="middle">mirror project for a.noir, provision scratch dir</text>

<line x1="360" y1="210" x2="380" y2="210" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="380,206 388,210 380,214" fill="#3a3a3a"/>

<rect x="388" y="174" width="220" height="72" fill="#080c14" stroke="#2a4060" stroke-width="1"/>
<text x="498" y="191" font-size="8" fill="#9cdcfe" letter-spacing="1.5" text-anchor="middle">SYMLINK MIRROR</text>
<text x="498" y="208" font-size="12" font-weight="700" fill="#d0d0d0" text-anchor="middle">mirrors/project/</text>
<text x="498" y="225" font-size="10" fill="#9cdcfe" text-anchor="middle">every file → symlink to source</text>
<text x="498" y="239" font-size="8.5" fill="#585858" text-anchor="middle">project r-x · settings.local.json denies</text>

<line x1="608" y1="210" x2="628" y2="210" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="628,206 636,210 628,214" fill="#3a3a3a"/>

<rect x="636" y="174" width="184" height="72" fill="#080e0e" stroke="#0e3a3a" stroke-width="1"/>
<text x="728" y="191" font-size="8" fill="#1affff" letter-spacing="1.5" text-anchor="middle">READS</text>
<text x="728" y="208" font-size="12" font-weight="700" fill="#d0d0d0" text-anchor="middle">source tree</text>
<text x="728" y="225" font-size="10" fill="#1affff" text-anchor="middle">via symlinks · read-only</text>
<text x="728" y="239" font-size="8.5" fill="#585858" text-anchor="middle">full project visible</text>

<!-- ROW 3 -->
<rect x="40" y="258" width="320" height="72" fill="#0d0b14" stroke="#3a3060" stroke-width="1"/>
<text x="200" y="272" font-size="8" fill="#9f9fcf" letter-spacing="1.5" text-anchor="middle">LAUNCH</text>
<text x="200" y="288" font-size="10" font-weight="700" fill="#d0d0d0" text-anchor="middle">rovibe launch &lt;agent&gt; &lt;project&gt;</text>
<text x="200" y="304" font-size="9" fill="#9f9fcf" text-anchor="middle">rovibe launch a.noir ~/repos/project</text>
<text x="200" y="320" font-size="8.5" fill="#585858" text-anchor="middle">start Claude Code session as a.noir OS user</text>

<line x1="360" y1="294" x2="380" y2="294" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="380,290 388,294 380,298" fill="#3a3a3a"/>

<rect x="388" y="258" width="220" height="72" fill="#080c14" stroke="#2a4060" stroke-width="1"/>
<text x="498" y="275" font-size="8" fill="#9cdcfe" letter-spacing="1.5" text-anchor="middle">EXECUTION</text>
<text x="498" y="292" font-size="12" font-weight="700" fill="#d0d0d0" text-anchor="middle">/opt/rovibe/a.noir/bin/</text>
<text x="498" y="309" font-size="10" fill="#9cdcfe" text-anchor="middle">allowed commands only · no sudo</text>
<text x="498" y="323" font-size="8.5" fill="#585858" text-anchor="middle">aa-exec confines at kernel level</text>

<line x1="608" y1="294" x2="628" y2="294" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="628,290 636,294 628,298" fill="#3a3a3a"/>

<rect x="636" y="258" width="184" height="72" fill="#080e0e" stroke="#0e3a3a" stroke-width="1"/>
<text x="728" y="275" font-size="8" fill="#1affff" letter-spacing="1.5" text-anchor="middle">WRITES</text>
<text x="728" y="292" font-size="12" font-weight="700" fill="#d0d0d0" text-anchor="middle">.scratch/ only</text>
<text x="728" y="309" font-size="10" fill="#1affff" text-anchor="middle">.scratch/reviews/a.noir/</text>
<text x="728" y="323" font-size="8.5" fill="#585858" text-anchor="middle">agent-owned · mode 700</text>

<!-- BOTTOM RULE -->
<!--
<line x1="40" y1="348" x2="820" y2="348" stroke="#1e1e1e" stroke-width="1"/>
-->

<!-- FOOTER -->
<!--
<text x="430" y="374" font-size="9" fill="#808080" text-anchor="middle">command execution scopes enforced by AppArmor</text>
-->

<!-- LEGEND -->
<!--
<rect x="286" y="418" width="9" height="9" fill="none" stroke="#5f5f87" stroke-width="1"/>
<text x="300" y="426" font-size="8" fill="#808080" letter-spacing="1">OPERATOR</text>
<rect x="378" y="418" width="9" height="9" fill="none" stroke="#2a5a8a" stroke-width="1"/>
<text x="392" y="426" font-size="8" fill="#808080" letter-spacing="1">ISOLATION</text>
<rect x="472" y="418" width="9" height="9" fill="none" stroke="#0e5a5a" stroke-width="1"/>
<text x="486" y="426" font-size="8" fill="#808080" letter-spacing="1">AGENT</text>
<rect x="544" y="418" width="9" height="9" fill="none" stroke="#5a1a1a" stroke-width="1"/>
<text x="558" y="426" font-size="8" fill="#808080" letter-spacing="1">BLOCKED</text>
-->
</g>
</svg>"""

def main():
    parser = argparse.ArgumentParser(description='Generate rovibe workflow SVG')
    parser.add_argument('--regular', required=True, help='Path to JetBrainsMono-Regular.ttf')
    parser.add_argument('--bold',    required=True, help='Path to JetBrainsMono-Bold.ttf')
    parser.add_argument('--output',  default='rovibe-diagram.svg', help='Output SVG path')
    args = parser.parse_args()

    reg_b64  = load_font(args.regular)
    bold_b64 = load_font(args.bold)

    svg = generate(reg_b64, bold_b64)

    with open(args.output, 'w') as f:
        f.write(svg)
    print(f"Written: {args.output}  ({len(svg):,} bytes)")

if __name__ == '__main__':
    main()
