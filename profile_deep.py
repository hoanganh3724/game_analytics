import duckdb

con = duckdb.connect("md:game_analytics_db")

tables = [
    "ad_impression", "buy_resource", "earn_resource", 
    "in_app_purchase", "level_end", "level_start", 
    "spend_resource", "winstreak_point_gained", "winstreak_reward_claimed"
]

output = []

for table in tables:
    output.append(f"\n==================================================")
    output.append(f"TABLE: main.{table}")
    output.append(f"==================================================")
    
    try:
        row_count = con.execute(f"SELECT COUNT(*) FROM main.{table}").fetchone()[0]
        output.append(f"Total Rows: {row_count:,}\n")
        
        columns = con.execute(f"PRAGMA table_info('main.{table}')").fetchall()
        
        for col in columns:
            col_name = col[1]
            col_type = col[2]
            
            # Thống kê cơ bản
            stats = con.execute(f"""
                SELECT 
                    COUNT(DISTINCT {col_name}) as distinct_cnt,
                    COUNT(*) - COUNT({col_name}) as null_cnt
                FROM main.{table}
            """).fetchone()
            
            distinct_cnt, null_cnt = stats[0], stats[1]
            null_pct = round((null_cnt / row_count) * 100, 2)
            
            output.append(f"📌 Cột: [{col_name}] | Type: {col_type} | Unique: {distinct_cnt:,} | Nulls: {null_cnt:,} ({null_pct}%)")
            
            # Nếu cột thuộc dạng số/ngày tháng -> Lấy Min / Max
            if any(t in col_type.upper() for t in ['INT', 'DOUBLE', 'FLOAT', 'DATE', 'TIMESTAMP', 'DECIMAL']):
                min_max = con.execute(f"SELECT MIN({col_name}), MAX({col_name}) FROM main.{table}").fetchone()
                output.append(f"   --> Range: Min = {min_max[0]} | Max = {min_max[1]}")
            
            # Nếu cột thuộc dạng Phân loại / Text / ID phân loại -> Top 5 giá trị phổ biến nhất
            if distinct_cnt <= 100 or 'VARCHAR' in col_type.upper():
                top_vals = con.execute(f"""
                    SELECT CAST({col_name} AS VARCHAR), COUNT(*) as cnt 
                    FROM main.{table} 
                    WHERE {col_name} IS NOT NULL
                    GROUP BY 1 
                    ORDER BY cnt DESC 
                    LIMIT 5
                """).fetchall()
                top_str = ", ".join([f"'{v[0]}': {v[1]:,}" for v in top_vals])
                output.append(f"   --> Top values: [{top_str}]")
            output.append("")
            
    except Exception as e:
        output.append(f"❌ Lỗi bảng main.{table}: {str(e)}\n")

with open("deep_raw_profile.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))

print("Xong! Đã xuất thông tin ngữ nghĩa 2.8GB dữ liệu ra 'deep_raw_profile.txt'.")