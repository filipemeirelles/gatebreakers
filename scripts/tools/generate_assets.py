import os

def ensure_dir(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)

def write_svg(path, content):
    ensure_dir(path)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content.strip())
    print(f"Created {path}")

# ==========================================
# 1. NAVIGATION & RESOURCE ICONS
# ==========================================

# Portals Icon: Dimensional gate vortex with glowing rings
ICON_PORTALS = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" width="96" height="96">
  <defs>
    <radialGradient id="portalCore" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#00f0ff" stop-opacity="1"/>
      <stop offset="45%" stop-color="#7000ff" stop-opacity="0.8"/>
      <stop offset="85%" stop-color="#180b38" stop-opacity="0.6"/>
      <stop offset="100%" stop-color="#090614" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="ringGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00f0ff"/>
      <stop offset="50%" stop-color="#a855f7"/>
      <stop offset="100%" stop-color="#3b82f6"/>
    </linearGradient>
  </defs>
  <rect width="96" height="96" rx="20" fill="#0b0d19" />
  <circle cx="48" cy="48" r="38" fill="url(#portalCore)" />
  <!-- Gate arch stones -->
  <path d="M 20 72 C 16 38 32 16 48 16 C 64 16 80 38 76 72" fill="none" stroke="#252c48" stroke-width="8" stroke-linecap="round"/>
  <!-- Energy swirl rings -->
  <ellipse cx="48" cy="50" rx="28" ry="22" fill="none" stroke="url(#ringGrad)" stroke-width="3.5" transform="rotate(-15 48 50)" stroke-dasharray="12 4"/>
  <ellipse cx="48" cy="50" rx="18" ry="14" fill="none" stroke="#00f0ff" stroke-width="2.5" transform="rotate(25 48 50)"/>
  <circle cx="48" cy="50" r="7" fill="#ffffff" />
  <circle cx="48" cy="50" r="12" fill="#00f0ff" opacity="0.4" />
  <!-- Runes / Accents -->
  <polygon points="48,10 52,18 44,18" fill="#00f0ff"/>
  <polygon points="18,68 24,64 22,72" fill="#7000ff"/>
  <polygon points="78,68 72,64 74,72" fill="#7000ff"/>
</svg>"""

# Hunter Icon: Crossed glowing daggers of Jinwoo
ICON_HUNTER = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" width="96" height="96">
  <defs>
    <linearGradient id="bladeGrad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="30%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#1e3a8a"/>
    </linearGradient>
    <linearGradient id="bladeGrad2" x1="100%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="30%" stop-color="#00f0ff"/>
      <stop offset="100%" stop-color="#4338ca"/>
    </linearGradient>
  </defs>
  <rect width="96" height="96" rx="20" fill="#0b0d19" />
  <!-- Background aura -->
  <circle cx="48" cy="48" r="32" fill="#00f0ff" opacity="0.12"/>
  <!-- Hunter crest diamond -->
  <polygon points="48,16 78,48 48,80 18,48" fill="none" stroke="#1e293b" stroke-width="3"/>
  <!-- Dagger 1 (Slash Left to Right) -->
  <g transform="rotate(45 48 48)">
    <path d="M 46 16 C 50 16 54 28 52 56 L 44 56 C 42 28 46 16 46 16 Z" fill="url(#bladeGrad1)"/>
    <rect x="42" y="56" width="12" height="4" rx="2" fill="#94a3b8"/>
    <rect x="45" y="60" width="6" height="18" rx="2" fill="#0f172a"/>
    <circle cx="48" cy="80" r="4" fill="#38bdf8"/>
  </g>
  <!-- Dagger 2 (Slash Right to Left) -->
  <g transform="rotate(-45 48 48)">
    <path d="M 46 16 C 50 16 54 28 52 56 L 44 56 C 42 28 46 16 46 16 Z" fill="url(#bladeGrad2)"/>
    <rect x="42" y="56" width="12" height="4" rx="2" fill="#94a3b8"/>
    <rect x="45" y="60" width="6" height="18" rx="2" fill="#0f172a"/>
    <circle cx="48" cy="80" r="4" fill="#00f0ff"/>
  </g>
  <!-- Center mana spark -->
  <circle cx="48" cy="48" r="5" fill="#ffffff"/>
  <circle cx="48" cy="48" r="10" fill="#00f0ff" opacity="0.4"/>
</svg>"""

# Shadows Icon: Shadow monarch crown & spectral helm
ICON_SHADOWS = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" width="96" height="96">
  <defs>
    <linearGradient id="shadowGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#9333ea"/>
      <stop offset="60%" stop-color="#3b0764"/>
      <stop offset="100%" stop-color="#0f0728"/>
    </linearGradient>
    <radialGradient id="eyeGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="50%" stop-color="#00f0ff"/>
      <stop offset="100%" stop-color="#00f0ff" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="96" height="96" rx="20" fill="#0b0d19" />
  <!-- Shadow mist aura -->
  <path d="M 24 78 Q 48 88 72 78 Q 80 50 72 32 Q 48 16 24 32 Q 16 50 24 78 Z" fill="url(#shadowGrad)" opacity="0.7"/>
  <!-- Helmet silhouette -->
  <path d="M 32 34 L 48 20 L 64 34 L 68 54 L 60 74 L 48 78 L 36 74 L 28 54 Z" fill="#120c24" stroke="#7e22ce" stroke-width="2.5"/>
  <!-- Crown horns -->
  <path d="M 32 34 L 22 18 L 36 26 L 48 14 L 60 26 L 74 18 L 64 34" fill="#2e1065" stroke="#a855f7" stroke-width="2"/>
  <!-- Glowing Monarch Eyes -->
  <ellipse cx="40" cy="50" rx="6" ry="2.5" fill="#00f0ff" transform="rotate(10 40 50)"/>
  <ellipse cx="56" cy="50" rx="6" ry="2.5" fill="#00f0ff" transform="rotate(-10 56 50)"/>
  <circle cx="40" cy="50" r="1.5" fill="#ffffff"/>
  <circle cx="56" cy="50" r="1.5" fill="#ffffff"/>
  <!-- Eye flare trails -->
  <path d="M 36 50 Q 24 46 16 38" fill="none" stroke="#00f0ff" stroke-width="2" opacity="0.8"/>
  <path d="M 60 50 Q 72 46 80 38" fill="none" stroke="#00f0ff" stroke-width="2" opacity="0.8"/>
</svg>"""

# Settings Icon: Futuristic hexagonal system core
ICON_SETTINGS = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" width="96" height="96">
  <defs>
    <linearGradient id="gearGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="50%" stop-color="#6366f1"/>
      <stop offset="100%" stop-color="#1e1b4b"/>
    </linearGradient>
  </defs>
  <rect width="96" height="96" rx="20" fill="#0b0d19" />
  <!-- Hexagonal Tech ring -->
  <polygon points="48,16 75,32 75,64 48,80 21,64 21,32" fill="none" stroke="url(#gearGrad)" stroke-width="4.5"/>
  <polygon points="48,24 68,36 68,60 48,72 28,60 28,36" fill="#111827" stroke="#334155" stroke-width="2"/>
  <!-- Cog teeth / brackets -->
  <rect x="44" y="10" width="8" height="10" rx="2" fill="#38bdf8"/>
  <rect x="44" y="76" width="8" height="10" rx="2" fill="#38bdf8"/>
  <rect x="13" y="44" width="10" height="8" rx="2" fill="#6366f1"/>
  <rect x="73" y="44" width="10" height="8" rx="2" fill="#6366f1"/>
  <!-- Inner core -->
  <circle cx="48" cy="48" r="10" fill="#0f172a" stroke="#00f0ff" stroke-width="2.5"/>
  <circle cx="48" cy="48" r="4" fill="#00f0ff"/>
</svg>"""

# Resource: Gold (Mana Crystal / Gold Monarch Coin)
ICON_GOLD = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">
  <defs>
    <linearGradient id="goldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#fef08a"/>
      <stop offset="40%" stop-color="#eab308"/>
      <stop offset="100%" stop-color="#854d0e"/>
    </linearGradient>
  </defs>
  <circle cx="32" cy="32" r="28" fill="#181308"/>
  <circle cx="32" cy="32" r="26" fill="url(#goldGrad)" stroke="#fef08a" stroke-width="1.5"/>
  <circle cx="32" cy="32" r="20" fill="#ca8a04"/>
  <!-- Facet crystal shape -->
  <polygon points="32,16 44,24 44,40 32,48 20,40 20,24" fill="#eab308" stroke="#fef08a" stroke-width="1.5"/>
  <polygon points="32,20 40,26 40,38 32,44 24,38 24,26" fill="#facc15"/>
  <polygon points="32,20 40,26 32,32 24,26" fill="#fef08a" opacity="0.9"/>
</svg>"""

# Resource: XP (Hunter Experience Flame / Blue Mana Core)
ICON_XP = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">
  <defs>
    <radialGradient id="xpCore" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="40%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#0284c7"/>
    </radialGradient>
    <linearGradient id="xpFlame" x1="0%" y1="100%" x2="0%" y2="0%">
      <stop offset="0%" stop-color="#0369a1"/>
      <stop offset="60%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#e0f2fe"/>
    </linearGradient>
  </defs>
  <circle cx="32" cy="32" r="28" fill="#081524"/>
  <!-- Mana flame flame -->
  <path d="M 32 8 C 38 18 48 24 48 38 C 48 48 40 56 32 56 C 24 56 16 48 16 38 C 16 26 26 18 32 8 Z" fill="url(#xpFlame)"/>
  <!-- Inner core flame -->
  <path d="M 32 20 C 35 26 40 30 40 38 C 40 44 36 48 32 48 C 28 48 24 44 24 38 C 24 30 29 26 32 20 Z" fill="#ffffff" opacity="0.85"/>
  <circle cx="32" cy="38" r="6" fill="#00f0ff"/>
</svg>"""

# Resource: Shadow Essence (Dark Violet Soul Flame)
ICON_ESSENCE = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">
  <defs>
    <linearGradient id="essFlame" x1="0%" y1="100%" x2="0%" y2="0%">
      <stop offset="0%" stop-color="#3b0764"/>
      <stop offset="40%" stop-color="#9333ea"/>
      <stop offset="85%" stop-color="#c084fc"/>
      <stop offset="100%" stop-color="#f5d0fe"/>
    </linearGradient>
  </defs>
  <circle cx="32" cy="32" r="28" fill="#14081e"/>
  <!-- Dark shadow soul flame -->
  <path d="M 32 6 C 42 16 50 26 50 40 C 50 50 42 58 32 58 C 22 58 14 50 14 40 C 14 28 22 16 32 6 Z" fill="url(#essFlame)"/>
  <!-- Swirling tendrils -->
  <path d="M 32 16 C 36 24 42 28 42 38 C 42 46 38 50 32 50 C 26 50 22 46 22 38 C 22 30 28 24 32 16 Z" fill="#581c87"/>
  <circle cx="32" cy="38" r="7" fill="#c084fc"/>
  <circle cx="32" cy="38" r="3" fill="#ffffff"/>
  <!-- Spectral eyes in essence -->
  <ellipse cx="29" cy="36" rx="2" ry="1" fill="#00f0ff"/>
  <ellipse cx="35" cy="36" rx="2" ry="1" fill="#00f0ff"/>
</svg>"""

# Stat Icons: HP, ATK, DEF, SPD
ICON_HP = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="hpGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#4ade80"/>
      <stop offset="100%" stop-color="#15803d"/>
    </linearGradient>
  </defs>
  <rect width="48" height="48" rx="10" fill="#051a0e"/>
  <path d="M 24 40 L 11 26 C 6 21 7 13 15 11 C 19 10 22 12 24 15 C 26 12 29 10 33 11 C 41 13 42 21 37 26 Z" fill="url(#hpGrad)"/>
  <path d="M 19 14 C 15 15 14 19 15 22" fill="none" stroke="#bbf7d0" stroke-width="2" stroke-linecap="round"/>
</svg>"""

ICON_ATK = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="atkGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#f87171"/>
      <stop offset="100%" stop-color="#b91c1c"/>
    </linearGradient>
  </defs>
  <rect width="48" height="48" rx="10" fill="#1c0808"/>
  <!-- Sword blade -->
  <g transform="rotate(45 24 24)">
    <path d="M 22 8 L 26 8 L 26 30 L 22 30 Z" fill="url(#atkGrad)"/>
    <polygon points="24,4 27,8 21,8" fill="#fecaca"/>
    <rect x="18" y="30" width="12" height="3" rx="1" fill="#94a3b8"/>
    <rect x="22" y="33" width="4" height="9" rx="1" fill="#475569"/>
    <circle cx="24" cy="43" r="2.5" fill="#f87171"/>
  </g>
</svg>"""

ICON_DEF = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="defGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#60a5fa"/>
      <stop offset="100%" stop-color="#1d4ed8"/>
    </linearGradient>
  </defs>
  <rect width="48" height="48" rx="10" fill="#081024"/>
  <path d="M 24 8 L 38 14 V 24 C 38 34 24 42 24 42 C 24 42 10 34 10 24 V 14 Z" fill="url(#defGrad)" stroke="#93c5fd" stroke-width="2"/>
  <path d="M 24 13 L 33 17 V 24 C 33 30 24 36 24 36 C 24 36 15 30 15 24 V 17 Z" fill="#1e3a8a" opacity="0.6"/>
</svg>"""

ICON_SPD = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="spdGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#0284c7"/>
    </linearGradient>
  </defs>
  <rect width="48" height="48" rx="10" fill="#061824"/>
  <!-- Winged swiftness icon / Lightning bolt -->
  <polygon points="26,6 12,24 22,24 18,42 36,20 26,20" fill="url(#spdGrad)" stroke="#bae6fd" stroke-width="1.5"/>
</svg>"""

ICON_BOSS = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="bossGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#ef4444"/>
      <stop offset="100%" stop-color="#7f1d1d"/>
    </linearGradient>
  </defs>
  <rect width="48" height="48" rx="10" fill="#1c0707"/>
  <!-- Demonic horned skull -->
  <path d="M 10 12 Q 16 18 16 24 L 32 24 Q 32 18 38 12 Q 32 8 28 16 L 20 16 Q 16 8 10 12 Z" fill="#991b1b"/>
  <path d="M 14 22 C 14 16 34 16 34 22 C 34 30 32 36 28 38 L 28 42 L 20 42 L 20 38 C 16 36 14 30 14 22 Z" fill="url(#bossGrad)" stroke="#fca5a5" stroke-width="1.5"/>
  <!-- Glowing red eye sockets -->
  <polygon points="18,26 23,28 19,32" fill="#ffffff"/>
  <polygon points="30,26 25,28 29,32" fill="#ffffff"/>
  <circle cx="20.5" cy="28.5" r="1.5" fill="#ef4444"/>
  <circle cx="27.5" cy="28.5" r="1.5" fill="#ef4444"/>
</svg>"""

ICON_LOCK = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <rect width="48" height="48" rx="10" fill="#14141e"/>
  <rect x="12" y="20" width="24" height="20" rx="4" fill="#334155" stroke="#64748b" stroke-width="2"/>
  <path d="M 17 20 V 14 C 17 9 31 9 31 14 V 20" fill="none" stroke="#94a3b8" stroke-width="3.5" stroke-linecap="round"/>
  <circle cx="24" cy="29" r="3" fill="#00f0ff"/>
  <rect x="23" y="29" width="2" height="5" fill="#00f0ff"/>
</svg>"""

# ==========================================
# 2. UNIT PORTRAITS (256x256)
# ==========================================

# SUNG JINWOO
PORTRAIT_JINWOO = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <radialGradient id="jwBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#1e1b4b"/>
      <stop offset="60%" stop-color="#0a0a16"/>
      <stop offset="100%" stop-color="#030308"/>
    </radialGradient>
    <linearGradient id="jwHair" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#0f172a"/>
      <stop offset="50%" stop-color="#020617"/>
      <stop offset="100%" stop-color="#000000"/>
    </linearGradient>
    <linearGradient id="jwSkin" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#fed7aa"/>
      <stop offset="70%" stop-color="#fdba74"/>
      <stop offset="100%" stop-color="#ca8a04"/>
    </linearGradient>
    <linearGradient id="jwCoat" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#090d16"/>
      <stop offset="50%" stop-color="#020617"/>
      <stop offset="100%" stop-color="#0c1a2e"/>
    </linearGradient>
    <radialGradient id="blueEyeGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="40%" stop-color="#00f0ff"/>
      <stop offset="100%" stop-color="#00f0ff" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <!-- Background -->
  <rect width="256" height="256" rx="28" fill="url(#jwBg)" />
  <!-- Border with glowing cyan accent -->
  <rect x="4" y="4" width="248" height="248" rx="24" fill="none" stroke="#1e293b" stroke-width="4"/>
  <rect x="4" y="4" width="248" height="248" rx="24" fill="none" stroke="#00f0ff" stroke-width="2" opacity="0.6"/>

  <!-- Shadow Monarch Mana Aura -->
  <path d="M 40 256 Q 30 140 70 80 Q 128 30 186 80 Q 226 140 216 256 Z" fill="#1e1b4b" opacity="0.6"/>
  <path d="M 60 256 Q 50 160 85 100 Q 128 60 171 100 Q 206 160 196 256 Z" fill="#00f0ff" opacity="0.15"/>

  <!-- High collar Coat & Shoulders -->
  <path d="M 28 256 L 68 180 L 100 170 L 128 190 L 156 170 L 188 180 L 228 256 Z" fill="url(#jwCoat)"/>
  <!-- Coat collar wings -->
  <polygon points="76,180 96,128 116,170" fill="#0f172a" stroke="#00f0ff" stroke-width="1.5"/>
  <polygon points="180,180 160,128 140,170" fill="#0f172a" stroke="#00f0ff" stroke-width="1.5"/>
  <!-- Inner shirt -->
  <polygon points="116,170 128,210 140,170 128,155" fill="#020617"/>

  <!-- Neck & Face -->
  <polygon points="118,145 128,175 138,145" fill="#ea580c" opacity="0.6"/>
  <!-- Jawline & Face -->
  <polygon points="98,95 158,95 154,130 128,162 102,130" fill="url(#jwSkin)"/>

  <!-- Mouth & Nose -->
  <line x1="124" y1="140" x2="134" y2="139" stroke="#9a3412" stroke-width="2.5" stroke-linecap="round"/>
  <polygon points="126,124 128,128 124,129" fill="#9a3412"/>

  <!-- EYES - Piercing glowing blue Monarch Eyes -->
  <polygon points="106,110 118,114 110,116" fill="#0f172a"/>
  <polygon points="150,110 138,114 146,116" fill="#0f172a"/>
  <!-- Glowing Iris -->
  <ellipse cx="112" cy="113" rx="5" ry="2.5" fill="#00f0ff"/>
  <ellipse cx="144" cy="113" rx="5" ry="2.5" fill="#00f0ff"/>
  <circle cx="112" cy="113" r="1.5" fill="#ffffff"/>
  <circle cx="144" cy="113" r="1.5" fill="#ffffff"/>
  <!-- Blue Eye Flame Trail -->
  <path d="M 108 113 Q 86 105 76 90" fill="none" stroke="#00f0ff" stroke-width="3" stroke-linecap="round" opacity="0.9"/>
  <path d="M 148 113 Q 170 105 180 90" fill="none" stroke="#00f0ff" stroke-width="3" stroke-linecap="round" opacity="0.9"/>

  <!-- Sharp Black Hair with Spikes -->
  <path d="M 90 95 C 80 60 110 40 128 40 C 146 40 176 60 166 95 L 176 80 L 160 62 L 178 52 L 148 34 L 132 24 L 118 36 L 90 48 L 102 65 L 82 82 Z" fill="url(#jwHair)"/>
  <!-- Hair bangs over forehead -->
  <polygon points="98,90 110,112 116,92" fill="#090d16"/>
  <polygon points="118,88 126,118 132,88" fill="#020617"/>
  <polygon points="138,88 144,110 156,92" fill="#090d16"/>
  <!-- Hair sheen -->
  <path d="M 112 48 Q 128 42 144 48" fill="none" stroke="#38bdf8" stroke-width="2" opacity="0.6"/>

  <!-- Dagger Hilt in Foreground -->
  <g transform="translate(160, 160) rotate(-25)">
    <rect x="0" y="0" width="10" height="70" rx="3" fill="#0f172a" stroke="#00f0ff" stroke-width="2"/>
    <circle cx="5" cy="72" r="7" fill="#0284c7"/>
    <rect x="-8" y="-4" width="26" height="8" rx="2" fill="#38bdf8"/>
    <polygon points="-4,-4 5,-40 14,-4" fill="#e0f2fe" stroke="#38bdf8" stroke-width="1.5"/>
  </g>

  <!-- Title Badge Label -->
  <rect x="36" y="214" width="184" height="28" rx="8" fill="#0a0f1d" stroke="#00f0ff" stroke-width="1.5"/>
  <text x="128" y="233" fill="#00f0ff" font-family="sans-serif" font-size="13" font-weight="bold" text-anchor="middle" letter-spacing="1.5">SUNG JINWOO</text>
</svg>"""

# SHADOW SOLDIER
PORTRAIT_SHADOW_SOLDIER = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <radialGradient id="ssBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#2e1065"/>
      <stop offset="65%" stop-color="#0f0728"/>
      <stop offset="100%" stop-color="#05020c"/>
    </radialGradient>
    <linearGradient id="ssArmor" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#1e113a"/>
      <stop offset="50%" stop-color="#0d071a"/>
      <stop offset="100%" stop-color="#05020a"/>
    </linearGradient>
  </defs>
  <rect width="256" height="256" rx="28" fill="url(#ssBg)" />
  <rect x="4" y="4" width="248" height="248" rx="24" fill="none" stroke="#7e22ce" stroke-width="3" opacity="0.7"/>

  <!-- Shadow Mist Aura -->
  <path d="M 30 256 Q 20 150 60 90 Q 128 40 196 90 Q 236 150 226 256 Z" fill="#581c87" opacity="0.4"/>
  <path d="M 50 256 Q 40 180 80 120 Q 128 70 176 120 Q 216 180 206 256 Z" fill="#9333ea" opacity="0.2"/>

  <!-- Heavy Armored Shoulders -->
  <path d="M 32 256 L 64 190 L 104 180 L 128 200 L 152 180 L 192 190 L 224 256 Z" fill="url(#ssArmor)"/>
  <!-- Pauldron Spikes -->
  <polygon points="54,190 40,160 70,175" fill="#3b0764" stroke="#a855f7" stroke-width="1.5"/>
  <polygon points="202,190 216,160 186,175" fill="#3b0764" stroke="#a855f7" stroke-width="1.5"/>

  <!-- Shadow Knight Helmet -->
  <path d="M 88 150 L 80 90 L 104 50 L 128 32 L 152 50 L 176 90 L 168 150 L 128 175 Z" fill="url(#ssArmor)" stroke="#7e22ce" stroke-width="2"/>
  <!-- Helmet Horns -->
  <path d="M 96 64 L 64 36 L 90 46" fill="#1e113a" stroke="#a855f7" stroke-width="2"/>
  <path d="M 160 64 L 192 36 L 166 46" fill="#1e113a" stroke="#a855f7" stroke-width="2"/>

  <!-- Visor Slit -->
  <polygon points="96,112 160,112 154,124 128,128 102,124" fill="#000000"/>
  <!-- Glowing Blue Shadow Eyes inside Helmet -->
  <ellipse cx="114" cy="118" rx="8" ry="3" fill="#00f0ff"/>
  <ellipse cx="142" cy="118" rx="8" ry="3" fill="#00f0ff"/>
  <circle cx="114" cy="118" r="2" fill="#ffffff"/>
  <circle cx="142" cy="118" r="2" fill="#ffffff"/>

  <!-- Eye mist flares -->
  <path d="M 108 118 Q 80 114 68 100" fill="none" stroke="#00f0ff" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M 148 118 Q 176 114 188 100" fill="none" stroke="#00f0ff" stroke-width="2.5" stroke-linecap="round"/>

  <!-- Broadsword behind back -->
  <polygon points="124,10 132,10 134,70 122,70" fill="#475569" stroke="#94a3b8" stroke-width="1.5"/>

  <!-- Title Badge Label -->
  <rect x="32" y="214" width="192" height="28" rx="8" fill="#100720" stroke="#a855f7" stroke-width="1.5"/>
  <text x="128" y="233" fill="#c084fc" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" letter-spacing="1">SOLDADO DAS SOMBRAS</text>
</svg>"""

# SHADOW RANGED (Shadow Archer / Mage)
PORTRAIT_SHADOW_RANGED = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <radialGradient id="srBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#1e1b4b"/>
      <stop offset="65%" stop-color="#0b0f24"/>
      <stop offset="100%" stop-color="#03040c"/>
    </radialGradient>
  </defs>
  <rect width="256" height="256" rx="28" fill="url(#srBg)" />
  <rect x="4" y="4" width="248" height="248" rx="24" fill="none" stroke="#38bdf8" stroke-width="3" opacity="0.6"/>

  <!-- Spectral Wind / Mana Aura -->
  <path d="M 40 256 Q 30 140 70 80 Q 128 35 186 80 Q 226 140 216 256 Z" fill="#0c4a6e" opacity="0.4"/>

  <!-- Shadow Cloak & Hood -->
  <path d="M 40 256 L 76 190 L 110 180 L 128 195 L 146 180 L 180 190 L 216 256 Z" fill="#082f49"/>
  <!-- Giant Deep Hood -->
  <path d="M 80 160 C 70 80 100 40 128 36 C 156 40 186 80 176 160 C 160 175 140 180 128 180 C 116 180 96 175 80 160 Z" fill="#0c1e34" stroke="#0284c7" stroke-width="2"/>
  <!-- Abyss inside Hood -->
  <path d="M 94 150 C 88 100 110 70 128 68 C 146 70 168 100 162 150 C 150 162 136 166 128 166 C 120 166 106 162 94 150 Z" fill="#020617"/>

  <!-- Glowing Cyan Eyes in Abyss -->
  <ellipse cx="114" cy="116" rx="7" ry="2.5" fill="#38bdf8" transform="rotate(5 114 116)"/>
  <ellipse cx="142" cy="116" rx="7" ry="2.5" fill="#38bdf8" transform="rotate(-5 142 116)"/>
  <circle cx="114" cy="116" r="1.5" fill="#ffffff"/>
  <circle cx="142" cy="116" r="1.5" fill="#ffffff"/>
  <!-- Eye flare trails -->
  <path d="M 108 116 Q 84 110 72 96" fill="none" stroke="#38bdf8" stroke-width="2" stroke-linecap="round"/>
  <path d="M 148 116 Q 172 110 184 96" fill="none" stroke="#38bdf8" stroke-width="2" stroke-linecap="round"/>

  <!-- Spectral Bow across chest -->
  <path d="M 190 50 Q 210 130 190 210" fill="none" stroke="#00f0ff" stroke-width="4.5" stroke-linecap="round"/>
  <!-- Bowstring -->
  <line x1="190" y1="50" x2="190" y2="210" stroke="#e0f2fe" stroke-width="1.5" stroke-dasharray="4 2"/>
  <!-- Glowing Arrow -->
  <line x1="140" y1="130" x2="220" y2="130" stroke="#ffffff" stroke-width="2.5"/>
  <polygon points="220,130 210,125 210,135" fill="#38bdf8"/>

  <!-- Title Badge Label -->
  <rect x="36" y="214" width="184" height="28" rx="8" fill="#081e30" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="128" y="233" fill="#38bdf8" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" letter-spacing="1">SOMBRA ATIRADORA</text>
</svg>"""

# SHADOW GUARDIAN (Shadow Tank / Fortress)
PORTRAIT_SHADOW_GUARDIAN = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <radialGradient id="sgBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#1e293b"/>
      <stop offset="65%" stop-color="#0f172a"/>
      <stop offset="100%" stop-color="#020617"/>
    </radialGradient>
  </defs>
  <rect width="256" height="256" rx="28" fill="url(#sgBg)" />
  <rect x="4" y="4" width="248" height="248" rx="24" fill="none" stroke="#64748b" stroke-width="3" opacity="0.6"/>

  <!-- Iron Fortress Pauldrons (Massive heavy armor) -->
  <path d="M 16 256 L 48 160 L 98 150 L 128 175 L 158 150 L 208 160 L 240 256 Z" fill="#0f172a" stroke="#334155" stroke-width="3"/>
  <!-- Pauldron Armor Plates -->
  <polygon points="24,180 56,150 78,190 38,210" fill="#1e293b" stroke="#00f0ff" stroke-width="1.5"/>
  <polygon points="232,180 200,150 178,190 218,210" fill="#1e293b" stroke="#00f0ff" stroke-width="1.5"/>

  <!-- Bulky Fortress Helmet -->
  <path d="M 80 150 L 74 80 L 100 40 L 128 26 L 156 40 L 182 80 L 176 150 L 128 178 Z" fill="#0f172a" stroke="#475569" stroke-width="3"/>
  <!-- Tower Horns -->
  <polygon points="80,50 50,20 76,32" fill="#1e293b" stroke="#64748b" stroke-width="2"/>
  <polygon points="176,50 206,20 180,32" fill="#1e293b" stroke="#64748b" stroke-width="2"/>

  <!-- Heavy Triple-Slit Visor with Blue Core -->
  <rect x="96" y="96" width="64" height="6" rx="2" fill="#000000"/>
  <rect x="100" y="108" width="56" height="6" rx="2" fill="#000000"/>
  <rect x="104" y="120" width="48" height="6" rx="2" fill="#000000"/>

  <rect x="110" y="97" width="36" height="4" rx="1" fill="#00f0ff"/>
  <rect x="114" y="109" width="28" height="4" rx="1" fill="#00f0ff"/>

  <!-- Tower Shield in front -->
  <path d="M 50 170 L 110 160 L 110 240 L 80 256 L 50 240 Z" fill="#1e293b" stroke="#00f0ff" stroke-width="2.5"/>
  <circle cx="80" cy="200" r="10" fill="none" stroke="#00f0ff" stroke-width="2"/>

  <!-- Title Badge Label -->
  <rect x="36" y="214" width="184" height="28" rx="8" fill="#0b1320" stroke="#64748b" stroke-width="1.5"/>
  <text x="128" y="233" fill="#94a3b8" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" letter-spacing="1">SOMBRA GUARDIÃ</text>
</svg>"""

# BLOOD-RED COMMANDER IGRIS
PORTRAIT_IGRIS = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <radialGradient id="igBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#450a0a"/>
      <stop offset="65%" stop-color="#1c0707"/>
      <stop offset="100%" stop-color="#050202"/>
    </radialGradient>
    <linearGradient id="igPlume" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#fca5a5"/>
      <stop offset="30%" stop-color="#ef4444"/>
      <stop offset="80%" stop-color="#991b1b"/>
      <stop offset="100%" stop-color="#450a0a"/>
    </linearGradient>
    <linearGradient id="igArmor" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#2d0b0b"/>
      <stop offset="50%" stop-color="#140505"/>
      <stop offset="100%" stop-color="#080202"/>
    </linearGradient>
  </defs>
  <rect width="256" height="256" rx="28" fill="url(#igBg)" />
  <rect x="4" y="4" width="248" height="248" rx="24" fill="none" stroke="#dc2626" stroke-width="3" opacity="0.8"/>

  <!-- Red Blood Aura / Monarch Fire -->
  <path d="M 40 256 Q 20 140 60 80 Q 128 30 196 80 Q 236 140 216 256 Z" fill="#7f1d1d" opacity="0.4"/>

  <!-- Iconic Long Flowing Red Plume from Helmet (Sweeping to the left/top) -->
  <path d="M 128 40 C 130 10 90 6 60 16 C 30 26 20 50 16 90 C 12 120 24 150 18 180 C 26 150 28 110 44 80 C 60 54 90 44 128 40 Z" fill="url(#igPlume)" stroke="#f87171" stroke-width="1.5"/>

  <!-- Commander Plate Armor Shoulders -->
  <path d="M 28 256 L 62 180 L 102 170 L 128 195 L 154 170 L 194 180 L 228 256 Z" fill="url(#igArmor)" stroke="#7f1d1d" stroke-width="2.5"/>
  <!-- Red Trim on Armor -->
  <path d="M 62 180 L 102 170 L 128 195 L 154 170 L 194 180" fill="none" stroke="#ef4444" stroke-width="2"/>

  <!-- Sleek Crimson Knight Helmet -->
  <path d="M 90 145 L 82 85 L 108 42 L 128 26 L 148 42 L 174 85 L 166 145 L 128 174 Z" fill="url(#igArmor)" stroke="#b91c1c" stroke-width="2"/>
  <!-- Helmet Crest Point -->
  <polygon points="128,20 134,36 122,36" fill="#ef4444"/>

  <!-- Visor Slit with terrifying White-Red Eye Glare -->
  <polygon points="98,106 158,106 152,118 128,122 104,118" fill="#000000"/>
  <ellipse cx="116" cy="112" rx="7" ry="2.5" fill="#ffffff"/>
  <ellipse cx="140" cy="112" rx="7" ry="2.5" fill="#ffffff"/>
  <ellipse cx="116" cy="112" rx="4" ry="1.5" fill="#ef4444"/>
  <ellipse cx="140" cy="112" rx="4" ry="1.5" fill="#ef4444"/>

  <!-- Red Lightning trails from eyes -->
  <path d="M 110 112 L 94 108 L 86 114 L 72 106" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round"/>
  <path d="M 146 112 L 162 108 L 170 114 L 184 106" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round"/>

  <!-- Giant Greatsword Blade behind -->
  <polygon points="186,10 200,10 196,160 190,160" fill="#0f0707" stroke="#dc2626" stroke-width="2"/>
  <line x1="193" y1="10" x2="193" y2="150" stroke="#fca5a5" stroke-width="1.5"/>

  <!-- Title Badge Label -->
  <rect x="36" y="214" width="184" height="28" rx="8" fill="#180404" stroke="#ef4444" stroke-width="1.5"/>
  <text x="128" y="233" fill="#f87171" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" letter-spacing="1">COMANDANTE IGRIS</text>
</svg>"""

# COMMON ENEMY (Dungeon Gate Goblin / Beast)
PORTRAIT_ENEMY_COMMON = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <radialGradient id="ecBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#1c1917"/>
      <stop offset="65%" stop-color="#0c0a09"/>
      <stop offset="100%" stop-color="#030303"/>
    </radialGradient>
    <linearGradient id="ecSkin" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#4d7c0f"/>
      <stop offset="60%" stop-color="#365314"/>
      <stop offset="100%" stop-color="#1a2e05"/>
    </linearGradient>
  </defs>
  <rect width="256" height="256" rx="28" fill="url(#ecBg)" />
  <rect x="4" y="4" width="248" height="248" rx="24" fill="none" stroke="#84cc16" stroke-width="2" opacity="0.6"/>

  <!-- Beastly Goblin Head & Horns -->
  <!-- Long pointed ears -->
  <polygon points="80,110 20,80 70,140" fill="#365314" stroke="#84cc16" stroke-width="1.5"/>
  <polygon points="176,110 236,80 186,140" fill="#365314" stroke="#84cc16" stroke-width="1.5"/>

  <!-- Face -->
  <path d="M 70 100 C 60 60 196 60 186 100 C 190 150 160 190 128 190 C 96 190 66 150 70 100 Z" fill="url(#ecSkin)"/>

  <!-- Jagged Horns -->
  <path d="M 90 70 Q 70 30 96 24 Q 106 50 100 70" fill="#292524" stroke="#78716c" stroke-width="1.5"/>
  <path d="M 166 70 Q 186 30 160 24 Q 150 50 156 70" fill="#292524" stroke="#78716c" stroke-width="1.5"/>

  <!-- Savage Glowing Red Eyes -->
  <circle cx="104" cy="110" r="10" fill="#ef4444"/>
  <circle cx="152" cy="110" r="10" fill="#ef4444"/>
  <circle cx="104" cy="110" r="4" fill="#fef08a"/>
  <circle cx="152" cy="110" r="4" fill="#fef08a"/>

  <!-- Fangs & Snarl -->
  <path d="M 104 150 Q 128 165 152 150" fill="none" stroke="#1c1917" stroke-width="3"/>
  <polygon points="112,150 116,165 120,150" fill="#f5f5f4"/>
  <polygon points="136,150 140,165 144,150" fill="#f5f5f4"/>

  <!-- Title Badge Label -->
  <rect x="36" y="214" width="184" height="28" rx="8" fill="#141c0e" stroke="#84cc16" stroke-width="1.5"/>
  <text x="128" y="233" fill="#a3e635" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" letter-spacing="1">MONSTRO DO PORTAL</text>
</svg>"""

# GATE BOSS (Demonic Titan / Dungeon Boss)
PORTRAIT_ENEMY_BOSS = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <radialGradient id="ebBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#450a0a"/>
      <stop offset="65%" stop-color="#180404"/>
      <stop offset="100%" stop-color="#080101"/>
    </radialGradient>
    <linearGradient id="ebHorn" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ef4444"/>
      <stop offset="50%" stop-color="#7f1d1d"/>
      <stop offset="100%" stop-color="#1c0404"/>
    </linearGradient>
  </defs>
  <rect width="256" height="256" rx="28" fill="url(#ebBg)" />
  <rect x="4" y="4" width="248" height="248" rx="24" fill="none" stroke="#ef4444" stroke-width="3.5" opacity="0.9"/>

  <!-- Massive Curved Demon Horns -->
  <path d="M 80 80 C 40 20 20 6 6 40 C -8 70 30 110 60 100 Z" fill="url(#ebHorn)" stroke="#fca5a5" stroke-width="2"/>
  <path d="M 176 80 C 216 20 236 6 250 40 C 264 70 226 110 196 100 Z" fill="url(#ebHorn)" stroke="#fca5a5" stroke-width="2"/>

  <!-- Demonic Titan Face -->
  <polygon points="68,90 188,90 178,170 128,205 78,170" fill="#1c0707" stroke="#7f1d1d" stroke-width="3"/>
  <!-- Magma Cracks on Face -->
  <path d="M 128 90 L 128 135 L 115 145 M 128 135 L 140 145" fill="none" stroke="#ef4444" stroke-width="2"/>

  <!-- 4 Burning Demon Eyes -->
  <ellipse cx="100" cy="115" rx="8" ry="4" fill="#ef4444"/>
  <ellipse cx="156" cy="115" rx="8" ry="4" fill="#ef4444"/>
  <circle cx="100" cy="115" r="2.5" fill="#fef08a"/>
  <circle cx="156" cy="115" r="2.5" fill="#fef08a"/>

  <ellipse cx="106" cy="130" rx="5" ry="2.5" fill="#ef4444"/>
  <ellipse cx="150" cy="130" rx="5" ry="2.5" fill="#ef4444"/>
  <circle cx="106" cy="130" r="1.5" fill="#ffffff"/>
  <circle cx="150" cy="130" r="1.5" fill="#ffffff"/>

  <!-- Roaring Maw with Lava Fangs -->
  <polygon points="98,160 158,160 150,185 128,195 106,185" fill="#000000" stroke="#b91c1c" stroke-width="2"/>
  <polygon points="106,160 112,172 118,160" fill="#fee2e2"/>
  <polygon points="124,160 128,174 132,160" fill="#fee2e2"/>
  <polygon points="138,160 144,172 150,160" fill="#fee2e2"/>

  <!-- Title Badge Label -->
  <rect x="36" y="214" width="184" height="28" rx="8" fill="#200404" stroke="#ef4444" stroke-width="1.5"/>
  <text x="128" y="233" fill="#ef4444" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" letter-spacing="1">CHEFE DO PORTAL</text>
</svg>"""

# ==========================================
# 3. SKILL ICONS (128x128)
# ==========================================

SKILL_DAGGER = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <rect width="128" height="128" rx="20" fill="#070c18"/>
  <rect x="4" y="4" width="120" height="120" rx="16" fill="none" stroke="#38bdf8" stroke-width="2.5"/>
  <!-- Curved Dagger Arc Slash -->
  <path d="M 20 100 Q 50 30 110 20" fill="none" stroke="#00f0ff" stroke-width="6" stroke-linecap="round"/>
  <path d="M 30 105 Q 60 45 105 35" fill="none" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Dagger Blade -->
  <g transform="translate(64, 64) rotate(-35)">
    <polygon points="0,-40 6,-10 3,25 -3,25 -6,-10" fill="#e0f2fe" stroke="#0284c7" stroke-width="2"/>
    <rect x="-8" y="25" width="16" height="4" rx="1" fill="#94a3b8"/>
    <rect x="-3" y="29" width="6" height="16" rx="1" fill="#0f172a"/>
    <circle cx="0" cy="48" r="3.5" fill="#38bdf8"/>
  </g>
  <!-- Sparks -->
  <circle cx="95" cy="30" r="3" fill="#ffffff"/>
  <circle cx="80" cy="45" r="2" fill="#00f0ff"/>
</svg>"""

SKILL_DOMINATOR = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <radialGradient id="domCore" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="40%" stop-color="#00f0ff"/>
      <stop offset="100%" stop-color="#1e1b4b" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="128" height="128" rx="20" fill="#070c18"/>
  <rect x="4" y="4" width="120" height="120" rx="16" fill="none" stroke="#00f0ff" stroke-width="2.5"/>
  <!-- Gravity / Telekinetic shockwave rings -->
  <circle cx="64" cy="64" r="48" fill="none" stroke="#00f0ff" stroke-width="2" opacity="0.4" stroke-dasharray="6 4"/>
  <circle cx="64" cy="64" r="36" fill="none" stroke="#38bdf8" stroke-width="2.5" opacity="0.7"/>
  <circle cx="64" cy="64" r="24" fill="url(#domCore)"/>
  <!-- Outstretched Ruler's Hand silhouette -->
  <path d="M 52 88 L 52 64 L 58 44 L 64 42 L 70 44 L 76 64 L 76 88 Z" fill="#0f172a" stroke="#00f0ff" stroke-width="2"/>
  <circle cx="64" cy="54" r="4" fill="#ffffff"/>
</svg>"""

SKILL_SHADOW_EXTRACT = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <rect width="128" height="128" rx="20" fill="#0d061c"/>
  <rect x="4" y="4" width="120" height="120" rx="16" fill="none" stroke="#a855f7" stroke-width="2.5"/>
  <!-- Shadow Mist Rising -->
  <path d="M 24 110 Q 34 70 54 60 Q 40 40 64 20 Q 88 40 74 60 Q 94 70 104 110 Z" fill="#3b0764" opacity="0.7"/>
  <path d="M 36 110 Q 44 80 58 70 Q 48 50 64 36 Q 80 50 70 70 Q 84 80 92 110 Z" fill="#6b21a8" opacity="0.5"/>
  <!-- Spectral Claws Rising -->
  <path d="M 44 95 Q 40 60 50 48" fill="none" stroke="#00f0ff" stroke-width="3" stroke-linecap="round"/>
  <path d="M 64 95 L 64 40" fill="none" stroke="#00f0ff" stroke-width="3.5" stroke-linecap="round"/>
  <path d="M 84 95 Q 88 60 78 48" fill="none" stroke="#00f0ff" stroke-width="3" stroke-linecap="round"/>
  <!-- Glowing Eye Pair Rising -->
  <ellipse cx="58" cy="68" rx="4" ry="2" fill="#00f0ff"/>
  <ellipse cx="70" cy="68" rx="4" ry="2" fill="#00f0ff"/>
  <!-- Subtitle Text ARISE -->
  <text x="64" y="112" fill="#c084fc" font-family="sans-serif" font-size="11" font-weight="bold" text-anchor="middle" letter-spacing="2">ERGA-SE</text>
</svg>"""

SKILL_SHADOW_STRIKE = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <rect width="128" height="128" rx="20" fill="#0d061c"/>
  <rect x="4" y="4" width="120" height="120" rx="16" fill="none" stroke="#9333ea" stroke-width="2.5"/>
  <!-- Downward Shadow Blade Strike -->
  <path d="M 24 24 L 104 104" stroke="#c084fc" stroke-width="7" stroke-linecap="round"/>
  <path d="M 28 20 L 108 100" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
  <path d="M 14 44 Q 54 84 94 124" fill="none" stroke="#7e22ce" stroke-width="3" opacity="0.6"/>
  <!-- Violet sparks -->
  <polygon points="64,64 54,60 64,56 74,60" fill="#a855f7"/>
  <circle cx="80" cy="80" r="3" fill="#ffffff"/>
</svg>"""

SKILL_SHADOW_SHOT = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <rect width="128" height="128" rx="20" fill="#071220"/>
  <rect x="4" y="4" width="120" height="120" rx="16" fill="none" stroke="#38bdf8" stroke-width="2.5"/>
  <!-- Piercing Energy Bolt -->
  <line x1="20" y1="108" x2="108" y2="20" stroke="#38bdf8" stroke-width="5" stroke-linecap="round"/>
  <line x1="24" y1="104" x2="104" y2="24" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Arrow Head -->
  <polygon points="112,16 94,22 106,34" fill="#00f0ff"/>
  <!-- Sonic Shockwave Rings -->
  <ellipse cx="64" cy="64" rx="24" ry="12" fill="none" stroke="#00f0ff" stroke-width="2" transform="rotate(-45 64 64)"/>
  <ellipse cx="80" cy="48" rx="16" ry="8" fill="none" stroke="#38bdf8" stroke-width="1.5" transform="rotate(-45 80 48)"/>
</svg>"""

SKILL_IRON_SHIELD = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <rect width="128" height="128" rx="20" fill="#0a121c"/>
  <rect x="4" y="4" width="120" height="120" rx="16" fill="none" stroke="#64748b" stroke-width="2.5"/>
  <!-- Giant Tower Shield Face -->
  <path d="M 64 18 L 100 32 V 70 C 100 95 64 112 64 112 C 64 112 28 95 28 70 V 32 Z" fill="#1e293b" stroke="#00f0ff" stroke-width="3.5"/>
  <!-- Runic Hex Core inside Shield -->
  <polygon points="64,44 80,54 80,74 64,84 48,74 48,54" fill="#0f172a" stroke="#00f0ff" stroke-width="2"/>
  <circle cx="64" cy="64" r="5" fill="#00f0ff"/>
</svg>"""

SKILL_COMMANDER_BLADE = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <rect width="128" height="128" rx="20" fill="#180404"/>
  <rect x="4" y="4" width="120" height="120" rx="16" fill="none" stroke="#ef4444" stroke-width="2.5"/>
  <!-- Crimson Greatsword Slash -->
  <path d="M 16 112 L 112 16" stroke="#ef4444" stroke-width="8" stroke-linecap="round"/>
  <path d="M 22 106 L 106 22" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
  <!-- Red Lightning Sparks -->
  <path d="M 40 40 L 52 50 L 46 60 L 60 72" fill="none" stroke="#fca5a5" stroke-width="2"/>
  <path d="M 80 80 L 92 70 L 86 60 L 98 50" fill="none" stroke="#fca5a5" stroke-width="2"/>
</svg>"""

# ==========================================
# 4. STORY CARD ART (512x320)
# ==========================================

# STORY 1: "O Sistema" (Floating Blue Holographic System Quest Window)
STORY_SYSTEM_INTRO = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 320" width="512" height="320">
  <defs>
    <radialGradient id="sysBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#0e1a38"/>
      <stop offset="60%" stop-color="#070a16"/>
      <stop offset="100%" stop-color="#020308"/>
    </radialGradient>
    <linearGradient id="sysBorder" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00f0ff"/>
      <stop offset="50%" stop-color="#3b82f6"/>
      <stop offset="100%" stop-color="#7000ff"/>
    </linearGradient>
  </defs>
  <rect width="512" height="320" rx="20" fill="url(#sysBg)"/>

  <!-- Matrix Grid Lines -->
  <line x1="0" y1="80" x2="512" y2="80" stroke="#1e293b" stroke-width="1" stroke-dasharray="8 8"/>
  <line x1="0" y1="160" x2="512" y2="160" stroke="#1e293b" stroke-width="1" stroke-dasharray="8 8"/>
  <line x1="0" y1="240" x2="512" y2="240" stroke="#1e293b" stroke-width="1" stroke-dasharray="8 8"/>
  <line x1="128" y1="0" x2="128" y2="320" stroke="#1e293b" stroke-width="1" stroke-dasharray="8 8"/>
  <line x1="256" y1="0" x2="256" y2="320" stroke="#1e293b" stroke-width="1" stroke-dasharray="8 8"/>
  <line x1="384" y1="0" x2="384" y2="320" stroke="#1e293b" stroke-width="1" stroke-dasharray="8 8"/>

  <!-- Holographic Floating System Window -->
  <rect x="40" y="30" width="432" height="260" rx="12" fill="#080f20" fill-opacity="0.9" stroke="url(#sysBorder)" stroke-width="3"/>

  <!-- Window Header Bar -->
  <rect x="40" y="30" width="432" height="44" rx="12" fill="#0c1836"/>
  <line x1="40" y1="74" x2="472" y2="74" stroke="#00f0ff" stroke-width="2"/>

  <!-- System Quest Exclamation Icon -->
  <circle cx="70" cy="52" r="14" fill="#0284c7" stroke="#00f0ff" stroke-width="2"/>
  <text x="70" y="58" fill="#ffffff" font-family="sans-serif" font-size="16" font-weight="bold" text-anchor="middle">!</text>

  <!-- Header Title -->
  <text x="96" y="58" fill="#00f0ff" font-family="sans-serif" font-size="16" font-weight="bold" letter-spacing="2">[ ALERTA DO SISTEMA ]</text>

  <!-- Brackets and Decorative Corner Accents -->
  <path d="M 52 42 L 44 42 L 44 50" fill="none" stroke="#00f0ff" stroke-width="3"/>
  <path d="M 460 42 L 468 42 L 468 50" fill="none" stroke="#00f0ff" stroke-width="3"/>
  <path d="M 44 278 L 44 286 L 52 286" fill="none" stroke="#00f0ff" stroke-width="3"/>
  <path d="M 468 278 L 468 286 L 460 286" fill="none" stroke="#00f0ff" stroke-width="3"/>

  <!-- Main Notification Message inside Window -->
  <rect x="64" y="96" width="384" height="48" rx="8" fill="#0c1836" stroke="#1e3a8a" stroke-width="1.5"/>
  <text x="256" y="126" fill="#e0f2fe" font-family="sans-serif" font-size="15" font-weight="bold" text-anchor="middle" letter-spacing="1">VOCÊ DESPERTOU COMO JOGADOR</text>

  <!-- Sub-details / Quest Box -->
  <rect x="64" y="160" width="384" height="110" rx="8" fill="#050a16" stroke="#0284c7" stroke-width="1"/>
  <text x="86" y="190" fill="#38bdf8" font-family="sans-serif" font-size="13" font-weight="bold">MISSÃO ATIVA: CONQUISTAR OS PORTAIS</text>
  <text x="86" y="216" fill="#94a3b8" font-family="sans-serif" font-size="12">Recompensa: Evolução de Caçador, Ouro e XP</text>
  <text x="86" y="240" fill="#94a3b8" font-family="sans-serif" font-size="12">Apenas você pode visualizar as mensagens do Sistema.</text>

  <circle cx="420" cy="215" r="18" fill="#0284c7" opacity="0.3"/>
  <circle cx="420" cy="215" r="10" fill="#00f0ff"/>
</svg>"""

# STORY 2: "Primeiro portal concluído" (Dimensional Gate Shattering / Beaming Portal)
STORY_FIRST_ADVANCE = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 320" width="512" height="320">
  <defs>
    <radialGradient id="portalBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="40%" stop-color="#1e1b4b"/>
      <stop offset="80%" stop-color="#080718"/>
      <stop offset="100%" stop-color="#020108"/>
    </radialGradient>
  </defs>
  <rect width="512" height="320" rx="20" fill="url(#portalBg)"/>

  <!-- Ancient Dungeon Archway -->
  <path d="M 120 320 L 120 140 C 120 60 392 60 392 140 L 392 320" fill="none" stroke="#1e293b" stroke-width="32" stroke-linecap="round"/>
  <path d="M 120 320 L 120 140 C 120 60 392 60 392 140 L 392 320" fill="none" stroke="#334155" stroke-width="12" stroke-linecap="round"/>

  <!-- Runic Energy Swirling inside Gate -->
  <ellipse cx="256" cy="180" rx="100" ry="120" fill="#00f0ff" opacity="0.2"/>
  <ellipse cx="256" cy="180" rx="70" ry="90" fill="#38bdf8" opacity="0.4"/>
  <ellipse cx="256" cy="180" rx="40" ry="60" fill="#ffffff" opacity="0.8"/>

  <!-- Light Beams exploding outwards -->
  <line x1="256" y1="180" x2="60" y2="40" stroke="#00f0ff" stroke-width="4" stroke-linecap="round"/>
  <line x1="256" y1="180" x2="452" y2="40" stroke="#00f0ff" stroke-width="4" stroke-linecap="round"/>
  <line x1="256" y1="180" x2="256" y2="10" stroke="#ffffff" stroke-width="5" stroke-linecap="round"/>
  <line x1="256" y1="180" x2="40" y2="280" stroke="#7000ff" stroke-width="3"/>
  <line x1="256" y1="180" x2="472" y2="280" stroke="#7000ff" stroke-width="3"/>

  <!-- Floating Crystal Shards -->
  <polygon points="170,120 185,100 190,130 175,140" fill="#e0f2fe" stroke="#38bdf8" stroke-width="1.5"/>
  <polygon points="320,110 335,90 345,120 325,130" fill="#e0f2fe" stroke="#38bdf8" stroke-width="1.5"/>

  <!-- Bottom Banner -->
  <rect x="96" y="260" width="320" height="38" rx="10" fill="#0b1328" stroke="#00f0ff" stroke-width="2"/>
  <text x="256" y="284" fill="#00f0ff" font-family="sans-serif" font-size="14" font-weight="bold" text-anchor="middle" letter-spacing="2">PORTAL CONCLUÍDO COM SUCESSO</text>
</svg>"""

# STORY 3: "A tropa de sombras cresce" (Jinwoo standing with Shadow Army rising)
STORY_SHADOW_TROOP = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 320" width="512" height="320">
  <defs>
    <radialGradient id="stBg" cx="50%" cy="50%" r="60%">
      <stop offset="0%" stop-color="#3b0764"/>
      <stop offset="50%" stop-color="#1e0538"/>
      <stop offset="100%" stop-color="#06010d"/>
    </radialGradient>
  </defs>
  <rect width="512" height="320" rx="20" fill="url(#stBg)"/>

  <!-- Rising Shadow Mist Ground -->
  <path d="M 0 320 Q 120 220 256 240 Q 380 220 512 320 Z" fill="#2e1065"/>
  <path d="M 0 320 Q 160 260 256 270 Q 360 260 512 320 Z" fill="#581c87" opacity="0.6"/>

  <!-- Shadow Army Silhouettes in Background -->
  <!-- Left Soldiers -->
  <path d="M 70 300 L 90 200 L 110 200 L 130 300 Z" fill="#0d041a"/>
  <circle cx="100" cy="185" r="16" fill="#0d041a"/>
  <ellipse cx="96" cy="185" rx="3" ry="1.5" fill="#00f0ff"/>
  <ellipse cx="104" cy="185" rx="3" ry="1.5" fill="#00f0ff"/>

  <path d="M 140 310 L 160 220 L 180 220 L 200 310 Z" fill="#120524"/>
  <circle cx="170" cy="205" r="14" fill="#120524"/>
  <ellipse cx="166" cy="205" rx="3" ry="1.5" fill="#00f0ff"/>
  <ellipse cx="174" cy="205" rx="3" ry="1.5" fill="#00f0ff"/>

  <!-- Right Soldiers -->
  <path d="M 310 310 L 330 220 L 350 220 L 370 310 Z" fill="#120524"/>
  <circle cx="340" cy="205" r="14" fill="#120524"/>
  <ellipse cx="336" cy="205" rx="3" ry="1.5" fill="#00f0ff"/>
  <ellipse cx="344" cy="205" rx="3" ry="1.5" fill="#00f0ff"/>

  <path d="M 380 300 L 400 200 L 420 200 L 440 300 Z" fill="#0d041a"/>
  <circle cx="410" cy="185" r="16" fill="#0d041a"/>
  <ellipse cx="406" cy="185" rx="3" ry="1.5" fill="#00f0ff"/>
  <ellipse cx="414" cy="185" rx="3" ry="1.5" fill="#00f0ff"/>

  <!-- JINWOO CENTER FIGURE -->
  <!-- Long dark Monarch Coat -->
  <path d="M 220 320 L 236 150 L 276 150 L 292 320 Z" fill="#030712"/>
  <circle cx="256" cy="120" r="22" fill="#030712"/>
  <!-- Glowing Monarch Eyes -->
  <ellipse cx="250" cy="120" rx="4" ry="2" fill="#00f0ff"/>
  <ellipse cx="262" cy="120" rx="4" ry="2" fill="#00f0ff"/>
  <!-- Eye flames -->
  <path d="M 248 120 Q 230 110 220 95" fill="none" stroke="#00f0ff" stroke-width="2.5"/>
  <path d="M 264 120 Q 282 110 292 95" fill="none" stroke="#00f0ff" stroke-width="2.5"/>

  <!-- Jinwoo's Outstretched Hand commanding the shadows -->
  <path d="M 276 160 L 320 180" stroke="#030712" stroke-width="12" stroke-linecap="round"/>
  <circle cx="325" cy="182" r="8" fill="#00f0ff" opacity="0.6"/>

  <!-- Top Banner "ERGA-SE" -->
  <text x="256" y="60" fill="#a855f7" font-family="sans-serif" font-size="28" font-weight="900" text-anchor="middle" letter-spacing="8">ERGA-SE</text>
  <text x="256" y="85" fill="#38bdf8" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" letter-spacing="2">A TROPA DE SOMBRAS DESPERTOU</text>
</svg>"""

# ==========================================
# 5. GATE RANK BADGES (64x64)
# ==========================================
def make_rank_badge(letter, border_color, fill_color, text_color):
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">
  <polygon points="32,4 58,16 58,44 32,60 6,44 6,16" fill="{fill_color}" stroke="{border_color}" stroke-width="3"/>
  <polygon points="32,10 52,20 52,40 32,52 12,40 12,20" fill="none" stroke="{border_color}" stroke-width="1" opacity="0.5"/>
  <text x="32" y="40" fill="{text_color}" font-family="sans-serif" font-size="26" font-weight="900" text-anchor="middle">{letter}</text>
</svg>"""

BADGE_E = make_rank_badge("E", "#78716c", "#1c1917", "#d6d3d1")
BADGE_D = make_rank_badge("D", "#94a3b8", "#0f172a", "#f8fafc")
BADGE_C = make_rank_badge("C", "#22c55e", "#052e16", "#86efac")
BADGE_B = make_rank_badge("B", "#3b82f6", "#082f49", "#93c5fd")
BADGE_A = make_rank_badge("A", "#a855f7", "#2e1065", "#d8b4fe")
BADGE_S = make_rank_badge("S", "#ef4444", "#450a0a", "#fef08a")

# ==========================================
# WRITE ALL ASSETS
# ==========================================
def main():
    base = os.path.join(os.path.dirname(__file__), "..", "..")

    # Icons
    write_svg(os.path.join(base, "assets", "icons", "icon_portals.svg"), ICON_PORTALS)
    write_svg(os.path.join(base, "assets", "icons", "icon_hunter.svg"), ICON_HUNTER)
    write_svg(os.path.join(base, "assets", "icons", "icon_shadows.svg"), ICON_SHADOWS)
    write_svg(os.path.join(base, "assets", "icons", "icon_settings.svg"), ICON_SETTINGS)
    write_svg(os.path.join(base, "assets", "icons", "icon_gold.svg"), ICON_GOLD)
    write_svg(os.path.join(base, "assets", "icons", "icon_xp.svg"), ICON_XP)
    write_svg(os.path.join(base, "assets", "icons", "icon_essence.svg"), ICON_ESSENCE)
    write_svg(os.path.join(base, "assets", "icons", "icon_hp.svg"), ICON_HP)
    write_svg(os.path.join(base, "assets", "icons", "icon_atk.svg"), ICON_ATK)
    write_svg(os.path.join(base, "assets", "icons", "icon_def.svg"), ICON_DEF)
    write_svg(os.path.join(base, "assets", "icons", "icon_spd.svg"), ICON_SPD)
    write_svg(os.path.join(base, "assets", "icons", "icon_boss.svg"), ICON_BOSS)
    write_svg(os.path.join(base, "assets", "icons", "icon_lock.svg"), ICON_LOCK)

    # Unit portraits
    write_svg(os.path.join(base, "assets", "units", "jinwoo.svg"), PORTRAIT_JINWOO)
    write_svg(os.path.join(base, "assets", "units", "shadow_soldier.svg"), PORTRAIT_SHADOW_SOLDIER)
    write_svg(os.path.join(base, "assets", "units", "shadow_ranged.svg"), PORTRAIT_SHADOW_RANGED)
    write_svg(os.path.join(base, "assets", "units", "shadow_guardian.svg"), PORTRAIT_SHADOW_GUARDIAN)
    write_svg(os.path.join(base, "assets", "units", "igris.svg"), PORTRAIT_IGRIS)
    write_svg(os.path.join(base, "assets", "units", "enemy_common.svg"), PORTRAIT_ENEMY_COMMON)
    write_svg(os.path.join(base, "assets", "units", "enemy_boss.svg"), PORTRAIT_ENEMY_BOSS)

    # Placeholders compatibility fallback
    write_svg(os.path.join(base, "assets", "placeholders", "unit_jinwoo.svg"), PORTRAIT_JINWOO)
    write_svg(os.path.join(base, "assets", "placeholders", "unit_shadow_soldier.svg"), PORTRAIT_SHADOW_SOLDIER)
    write_svg(os.path.join(base, "assets", "placeholders", "unit_shadow_ranged.svg"), PORTRAIT_SHADOW_RANGED)
    write_svg(os.path.join(base, "assets", "placeholders", "unit_shadow_guardian.svg"), PORTRAIT_SHADOW_GUARDIAN)
    write_svg(os.path.join(base, "assets", "placeholders", "unit_igris.svg"), PORTRAIT_IGRIS)

    # Skills
    write_svg(os.path.join(base, "assets", "skills", "skill_dagger.svg"), SKILL_DAGGER)
    write_svg(os.path.join(base, "assets", "skills", "skill_dominator.svg"), SKILL_DOMINATOR)
    write_svg(os.path.join(base, "assets", "skills", "skill_shadow_extract.svg"), SKILL_SHADOW_EXTRACT)
    write_svg(os.path.join(base, "assets", "skills", "skill_shadow_strike.svg"), SKILL_SHADOW_STRIKE)
    write_svg(os.path.join(base, "assets", "skills", "skill_shadow_shot.svg"), SKILL_SHADOW_SHOT)
    write_svg(os.path.join(base, "assets", "skills", "skill_iron_shield.svg"), SKILL_IRON_SHIELD)
    write_svg(os.path.join(base, "assets", "skills", "skill_commander_blade.svg"), SKILL_COMMANDER_BLADE)

    # Story Art
    write_svg(os.path.join(base, "assets", "story", "story_system_intro.svg"), STORY_SYSTEM_INTRO)
    write_svg(os.path.join(base, "assets", "story", "story_first_advance.svg"), STORY_FIRST_ADVANCE)
    write_svg(os.path.join(base, "assets", "story", "story_shadow_troop.svg"), STORY_SHADOW_TROOP)

    # Badges
    write_svg(os.path.join(base, "assets", "badges", "badge_rank_e.svg"), BADGE_E)
    write_svg(os.path.join(base, "assets", "badges", "badge_rank_d.svg"), BADGE_D)
    write_svg(os.path.join(base, "assets", "badges", "badge_rank_c.svg"), BADGE_C)
    write_svg(os.path.join(base, "assets", "badges", "badge_rank_b.svg"), BADGE_B)
    write_svg(os.path.join(base, "assets", "badges", "badge_rank_a.svg"), BADGE_A)
    write_svg(os.path.join(base, "assets", "badges", "badge_rank_s.svg"), BADGE_S)

    print("All assets successfully generated!")

if __name__ == "__main__":
    main()
