import duckdb

con = duckdb.connect("md:game_analytics_db")
tables = [
    "ad_impression", "buy_resource", "earn_resource", 
    "in_app_purchase", "level_end", "level_start", 
    "spend_resource", "winstreak_point_gained", "winstreak_reward_claimed"
]

for t in tables:
    cols = [c[1] for c in con.execute(f"PRAGMA table_info('main.{t}')").fetchall()]
    print(f"\n--- {t} ---")
    print(cols)