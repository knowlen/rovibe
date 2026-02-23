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
<text x="430" y="34" font-size="20" font-weight="700" fill="#ffffff" text-anchor="middle">rovibe</text>
<text x="430" y="52" font-size="10" fill="#808080" letter-spacing="2.5" text-anchor="middle">AGENT ISOLATION OVERVIEW</text>

<!-- COLUMN HEADERS -->
<text x="160" y="74" font-size="9" fill="#9f9fcf" letter-spacing="2" text-anchor="middle">OPERATOR</text>
<text x="432" y="74" font-size="9" fill="#9cdcfe" letter-spacing="2" text-anchor="middle">ISOLATION LAYER</text>
<text x="706" y="74" font-size="9" fill="#87ffff" letter-spacing="2" text-anchor="middle">AGENT</text>

<!-- TOP RULE -->
<line x1="40" y1="80" x2="820" y2="80" stroke="#1e1e1e" stroke-width="1"/>

<!-- VERTICAL COLUMN DIVIDERS (stop before footer) -->
<line x1="292" y1="80" x2="292" y2="348" stroke="#1e1e1e" stroke-width="1"/>
<line x1="572" y1="80" x2="572" y2="348" stroke="#1e1e1e" stroke-width="1"/>

<!-- ROW 1 -->
<rect x="40" y="90" width="240" height="72" fill="#0d0b14" stroke="#3a3060" stroke-width="1"/>
<text x="52" y="107" font-size="8" fill="#9f9fcf" letter-spacing="1.5">01 · CREATE AGENT</text>
<text x="52" y="124" font-size="12" font-weight="700" fill="#d0d0d0">rovibe create agent</text>
<text x="52" y="141" font-size="10" fill="#9f9fcf">agent.ro reviewer</text>
<text x="52" y="155" font-size="8.5" fill="#585858">agent.ro user · agents group · limited</text>

<line x1="280" y1="126" x2="300" y2="126" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="300,122 308,126 300,130" fill="#3a3a3a"/>

<rect x="308" y="90" width="252" height="72" fill="#080c14" stroke="#2a4060" stroke-width="1"/>
<text x="320" y="107" font-size="8" fill="#9cdcfe" letter-spacing="1.5">IDENTITY</text>
<text x="320" y="124" font-size="12" font-weight="700" fill="#d0d0d0">/home/agent.ro/</text>
<text x="320" y="141" font-size="10" fill="#9cdcfe">uid restricted · gid: agents</text>
<text x="320" y="155" font-size="8.5" fill="#585858">PATH=/opt/agents/bin  [readonly]</text>

<line x1="560" y1="126" x2="580" y2="126" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="580,122 588,126 580,130" fill="#3a3a3a"/>

<rect x="588" y="90" width="232" height="72" fill="#140808" stroke="#5a1a1a" stroke-width="1"/>
<text x="600" y="107" font-size="8" fill="#ff5f5f" letter-spacing="1.5">BLOCKED · CANNOT</text>
<text x="600" y="124" font-size="11" font-weight="700" fill="#d0d0d0">write source tree</text>
<text x="600" y="141" font-size="9.5" fill="#cc4444">git commit · git push</text>
<text x="600" y="155" font-size="8.5" fill="#585858">install packages · escalate privs</text>

<!-- ROW 2 -->
<rect x="40" y="174" width="240" height="72" fill="#0d0b14" stroke="#3a3060" stroke-width="1"/>
<text x="52" y="191" font-size="8" fill="#9f9fcf" letter-spacing="1.5">02 · ASSIGN REVIEWER</text>
<text x="52" y="208" font-size="12" font-weight="700" fill="#d0d0d0">rovibe assign reviewer</text>
<text x="52" y="225" font-size="10" fill="#9f9fcf">agent.ro ./project</text>
<text x="52" y="239" font-size="8.5" fill="#585858">mirror + scratch provisioned</text>

<line x1="280" y1="210" x2="300" y2="210" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="300,206 308,210 300,214" fill="#3a3a3a"/>

<rect x="308" y="174" width="252" height="72" fill="#080c14" stroke="#2a4060" stroke-width="1"/>
<text x="320" y="191" font-size="8" fill="#9cdcfe" letter-spacing="1.5">SYMLINK MIRROR</text>
<text x="320" y="208" font-size="12" font-weight="700" fill="#d0d0d0">mirrors/project/</text>
<text x="320" y="225" font-size="10" fill="#9cdcfe">every file → symlink to source</text>
<text x="320" y="239" font-size="8.5" fill="#585858">project: r-x only · independent CLAUDE.md</text>

<line x1="560" y1="210" x2="580" y2="210" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="580,206 588,210 580,214" fill="#3a3a3a"/>

<rect x="588" y="174" width="232" height="72" fill="#080e0e" stroke="#0e3a3a" stroke-width="1"/>
<text x="600" y="191" font-size="8" fill="#1affff" letter-spacing="1.5">READS</text>
<text x="600" y="208" font-size="12" font-weight="700" fill="#d0d0d0">source tree</text>
<text x="600" y="225" font-size="10" fill="#1affff">via symlinks · read-only</text>
<text x="600" y="239" font-size="8.5" fill="#585858">full project visible</text>

<!-- ROW 3 -->
<rect x="40" y="258" width="240" height="72" fill="#0d0b14" stroke="#3a3060" stroke-width="1"/>
<text x="52" y="275" font-size="8" fill="#9f9fcf" letter-spacing="1.5">03 · LAUNCH</text>
<text x="52" y="292" font-size="12" font-weight="700" fill="#d0d0d0">rovibe launch reviewer</text>
<text x="52" y="309" font-size="10" fill="#9f9fcf">agent.ro ./project</text>
<text x="52" y="323" font-size="8.5" fill="#585858">Claude Code started as OS user</text>

<line x1="280" y1="294" x2="300" y2="294" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="300,290 308,294 300,298" fill="#3a3a3a"/>

<rect x="308" y="258" width="252" height="72" fill="#080c14" stroke="#2a4060" stroke-width="1"/>
<text x="320" y="275" font-size="8" fill="#9cdcfe" letter-spacing="1.5">EXECUTION</text>
<text x="320" y="292" font-size="12" font-weight="700" fill="#d0d0d0">/opt/agents/bin/</text>
<text x="320" y="309" font-size="10" fill="#9cdcfe">allowed commands only · no sudo</text>
<text x="320" y="323" font-size="8.5" fill="#585858">relaxed settings.json for more autonomy</text>

<line x1="560" y1="294" x2="580" y2="294" stroke="#3a3a3a" stroke-width="1"/>
<polygon points="580,290 588,294 580,298" fill="#3a3a3a"/>

<rect x="588" y="258" width="232" height="72" fill="#080e0e" stroke="#0e3a3a" stroke-width="1"/>
<text x="600" y="275" font-size="8" fill="#1affff" letter-spacing="1.5">WRITES</text>
<text x="600" y="292" font-size="12" font-weight="700" fill="#d0d0d0">.scratch/ only</text>
<text x="600" y="309" font-size="10" fill="#1affff">.scratch/reviews/agent.ro/</text>
<text x="600" y="323" font-size="8.5" fill="#585858">sticky+setgid · mode 3770</text>

<!-- BOTTOM RULE -->
<line x1="40" y1="348" x2="820" y2="348" stroke="#1e1e1e" stroke-width="1"/>

<!-- KERNEL NOTE -->
<rect x="308" y="356" width="252" height="20" fill="#000000" stroke="#1a1a2a" stroke-width="1"/>
<text x="434" y="370" font-size="8" fill="#3a3a6a" letter-spacing="1.5" text-anchor="middle">KERNEL ENFORCED · NOT PROMPT BASED</text>

<!-- FOOTER -->
<text x="430" y="404" font-size="9" fill="#808080" text-anchor="middle">output files persist in (gid: agents) shared project level .scratch/ dirs between sessions</text>

<!-- LEGEND -->
<rect x="286" y="418" width="9" height="9" fill="none" stroke="#5f5f87" stroke-width="1"/>
<text x="300" y="426" font-size="8" fill="#808080" letter-spacing="1">OPERATOR</text>
<rect x="378" y="418" width="9" height="9" fill="none" stroke="#2a5a8a" stroke-width="1"/>
<text x="392" y="426" font-size="8" fill="#808080" letter-spacing="1">ISOLATION</text>
<rect x="472" y="418" width="9" height="9" fill="none" stroke="#0e5a5a" stroke-width="1"/>
<text x="486" y="426" font-size="8" fill="#808080" letter-spacing="1">AGENT</text>
<rect x="544" y="418" width="9" height="9" fill="none" stroke="#5a1a1a" stroke-width="1"/>
<text x="558" y="426" font-size="8" fill="#808080" letter-spacing="1">BLOCKED</text>

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
