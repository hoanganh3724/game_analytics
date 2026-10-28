import os
import sys
import duckdb

# Lấy MotherDuck Token từ biến môi trường đã cài trên máy/GitHub Secrets
MOTHERDUCK_TOKEN = os.getenv("MOTHERDUCK_TOKEN")

if not MOTHERDUCK_TOKEN:
    print("❌ ERROR: Khong tim thay MOTHERDUCK_TOKEN trong bien moi truong!")
    sys.exit(1)

# Kết nối MotherDuck an toàn
con = duckdb.connect(f"md:game_analytics_db?token={MOTHERDUCK_TOKEN}")

tables = [
    "ad_impression", "buy_resource", "earn_resource", "in_app_purchase",
    "level_end", "level_start", "spend_resource", 
    "winstreak_point_gained", "winstreak_reward_claimed"
]

for table in tables:
    parquet_file = f"../parquet_bronze/{table}.parquet"
    
    con.execute(f"""
        CREATE OR REPLACE TABLE {table} AS 
        SELECT * FROM read_parquet('{parquet_file}')
    """)
    print(f"✔ Successfully loaded table: {table}")

print("\n🎉 Đã nạp thành công toàn bộ 9 bảng dữ liệu thô lên MotherDuck Cloud!")