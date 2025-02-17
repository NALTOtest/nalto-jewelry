Nalto Jewelry System 💍
A FiveM QBCore jewelry system that allows players to equip, craft, and manage magical rings with unique buffs and effects.

Features
✅ Wearable Rings with Buffs – Players can equip different rings to gain special abilities like increased armor, stamina, health regen, or money boosts.
✅ Ring Durability System – Rings degrade over time and can be repaired at a jeweler shop.
✅ Crafting & Materials – Players can craft rings using special materials from a dedicated jewelry shop.
✅ Buff System – Rings provide active buffs (e.g., faster swimming, sprint boosts, stress relief, extra armor).
✅ Stash & Inventory Integration – Uses ps-inventory for stash management and validation.
✅ Persistence & Server Restart Safety – Rings are returned to players after a server restart, even if they logged out before the restart.

Installation
Add the script to your resources folder.
Ensure ps-inventory and qb-core are installed.
Run this SQL query to enable persistence:
sql
Copy
Edit


CREATE TABLE IF NOT EXISTS player_rings (
    citizenid VARCHAR(50) PRIMARY KEY,
    ring_name VARCHAR(50) NOT NULL,
    ring_info TEXT NOT NULL
);


Add ensure nalto-jewelry to your server.cfg.
Restart your server and enjoy!
Planned Features
🔹 More ring types with unique effects.
🔹 Customizable crafting recipes in the config.
🔹 Additional jewelry items (necklaces, bracelets, etc.).
