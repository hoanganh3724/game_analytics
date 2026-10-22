import duckdb

MOTHERDUCK_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImhvYW5nYW5oMjQ1MzM2OUBnbWFpbC5jb20iLCJtZFJlZ2lvbiI6ImF3cy1hcC1ub3J0aGVhc3QtMSIsInNlc3Npb24iOiJob2FuZ2FuaDI0NTMzNjkuZ21haWwuY29tIiwicGF0IjoiZnBsOUNYRl9lWVBNM2dUNVhUMEdDSDRmS01uc21NemFPT1lVcVloYnY3cyIsInVzZXJJZCI6IjljZjkwMTBhLWQxZGEtNDViZS1hZTFiLWJlMmJhNmFmY2ZhZiIsImlzcyI6Im1kX3BhdCIsInJlYWRPbmx5IjpmYWxzZSwidG9rZW5UeXBlIjoicmVhZF93cml0ZSIsImlhdCI6MTc5MjYxNzg1MX0.vqlyYOTR8qjMqhfjDpna_4eKXi1tAjz_Kg-xKkXJ5vU"

# Kết nối MotherDuck
con = duckdb.connect(f"md:game_analytics_db?token={MOTHERDUCK_TOKEN}")

tables = [
    "ad_impression", "buy_resource", "earn_resource", "in_app_purchase",
    "level_end", "level_start", "spend_resource", 
    "winstreak_point_gained", "winstreak_reward_claimed"
]

for table in tables:
    # Trỏ trực tiếp vào file .parquet đơn lẻ trong thư mục ../parquet_bronze
    parquet_file = f"../parquet_bronze/{table}.parquet"
    
    con.execute(f"""
        CREATE OR REPLACE TABLE {table} AS 
        SELECT * FROM read_parquet('{parquet_file}')
    """)
    print(f"✔ Successfully loaded table: {table}")

print("\n🎉 Đã nạp thành công toàn bộ 9 bảng dữ liệu thô lên MotherDuck Cloud!")