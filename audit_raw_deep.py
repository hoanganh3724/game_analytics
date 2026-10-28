import duckdb

# Kết nối trực tiếp tới MotherDuck
con = duckdb.connect("md:game_analytics_db")

tables = [
    "ad_impression", "buy_resource", "earn_resource", 
    "in_app_purchase", "level_end", "level_start", 
    "spend_resource", "winstreak_point_gained", "winstreak_reward_claimed"
]

output = []

# --------------------------------------------------
# 1. KIỂM TRA CỘT NULL 100% HOẶC CHỈ CHỨA '\N' TRÊN 9 BẢNG (ĐỂ DROP CỘT RÁC)
# --------------------------------------------------
output.append("==================================================")
output.append("1. DANH SÁCH CỘT RÁC (NULL 100% HOẶC '\\N') NÊN DROP")
output.append("==================================================")

for table in tables:
    columns = con.execute(f"PRAGMA table_info('main.{table}')").fetchall()
    null_100_cols = []
    row_cnt = con.execute(f"SELECT COUNT(*) FROM main.{table}").fetchone()[0]
    
    for col in columns:
        col_name = col[1]
        null_cnt = con.execute(f"""
            SELECT COUNT(*) FROM main.{table} 
            WHERE {col_name} IS NULL 
               OR CAST({col_name} AS VARCHAR) = '\\N' 
               OR TRIM(CAST({col_name} AS VARCHAR)) = ''
        """).fetchone()[0]
        
        if null_cnt == row_cnt:
            null_100_cols.append(col_name)
            
    output.append(f"-> Table main.{table}: {null_100_cols}")

# --------------------------------------------------
# 2. KIỂM TRA DỮ LIỆU TRÙNG LẶP (DUPLICATE ROWS)
# --------------------------------------------------
output.append("\n==================================================")
output.append("2. KIỂM TRA DỮ LIỆU TRÙNG LẶP (DUPLICATES)")
output.append("==================================================")

for table in ["level_start", "level_end", "ad_impression", "in_app_purchase"]:
    dup_cnt = con.execute(f"""
        SELECT COUNT(*) - COUNT(DISTINCT (user_pseudo_id || '_' || CAST(event_timestamp AS VARCHAR)))
        FROM main.{table}
    """).fetchone()[0]
    output.append(f"-> Duplicates in main.{table}: {dup_cnt:,} rows")

# --------------------------------------------------
# 3. AUDIT KHÓA JOIN & ĐỘ KHỚP GA_SESSION_ID
# --------------------------------------------------
output.append("\n==================================================")
output.append("3. AUDIT KHÓA JOIN & ĐỘ KHỚP GA_SESSION_ID")
output.append("==================================================")

session_match = con.execute("""
    SELECT 
        COUNT(DISTINCT s.ga_session_id) as start_sessions,
        COUNT(DISTINCT e.ga_session_id) as end_sessions,
        COUNT(DISTINCT CASE WHEN e.ga_session_id IS NOT NULL THEN s.ga_session_id END) as matched_sessions
    FROM main.level_start s
    LEFT JOIN main.level_end e 
      ON s.user_pseudo_id = e.user_pseudo_id 
     AND CAST(s.ga_session_id AS VARCHAR) = CAST(e.ga_session_id AS VARCHAR)
""").fetchone()
output.append(f"-> Sessions Match (Start vs End): Start = {session_match[0]:,}, End = {session_match[1]:,}, Matched = {session_match[2]:,}")

# --------------------------------------------------
# 4. ĐO ĐỘ TRỄ THỜI GIAN GIỮA LEVEL_END VÀ WINSTREAK_POINTS (TIME-WINDOW MATCHING)
# --------------------------------------------------
output.append("\n==================================================")
output.append("4. ĐO ĐỘ TRỄ THỜI GIAN GIỮA LEVEL_END VÀ WINSTREAK_POINTS")
output.append("==================================================")

delay_stats = con.execute("""
    WITH matched AS (
        SELECT 
            p.user_pseudo_id,
            p.event_timestamp as p_ts,
            MAX(e.event_timestamp) as e_ts
        FROM main.winstreak_point_gained p
        JOIN main.level_end e 
          ON p.user_pseudo_id = e.user_pseudo_id 
         AND e.status = 1 
         AND e.event_timestamp <= p.event_timestamp
        GROUP BY p.user_pseudo_id, p.event_timestamp
    )
    SELECT 
        MIN(p_ts - e_ts) / 1000000.0 as min_delay_sec,
        AVG(p_ts - e_ts) / 1000000.0 as avg_delay_sec,
        MAX(p_ts - e_ts) / 1000000.0 as max_delay_sec,
        QUANTILE_CONT(p_ts - e_ts, 0.95) / 1000000.0 as p95_delay_sec
    FROM matched
""").fetchone()
output.append(f"-> Time Delay (seconds): Min = {delay_stats[0]}, Avg = {delay_stats[1]:.2f}s, Max = {delay_stats[2]}s, P95 = {delay_stats[3]:.2f}s")

# --------------------------------------------------
# 5. MAPPING USER_PSEUDO_ID VỚI PLAYER_ID
# --------------------------------------------------
output.append("\n==================================================")
output.append("5. MAPPING BETWEEN USER_PSEUDO_ID AND PLAYER_ID")
output.append("==================================================")

user_id_check = con.execute("""
    SELECT COUNT(DISTINCT user_pseudo_id), COUNT(DISTINCT player_id)
    FROM main.level_start
    WHERE player_id IS NOT NULL AND player_id != '\\N'
""").fetchone()
output.append(f"-> Unique user_pseudo_id: {user_id_check[0]:,} | Unique player_id: {user_id_check[1]:,}")

# --------------------------------------------------
# 6. SOI MẪU CHUỖI A/B TEST
# --------------------------------------------------
output.append("\n==================================================")
output.append("6. A/B TEST SAMPLE STRINGS")
output.append("==================================================")

ab_samples = con.execute("SELECT DISTINCT ab_test FROM main.level_start WHERE ab_test IS NOT NULL AND ab_test != '\\N' LIMIT 5").fetchall()
output.append(f"-> AB Test Samples: {[s[0] for s in ab_samples]}")

# --------------------------------------------------
# 7. DANH MỤC NGUỒN TIÊU TIỀN (SPEND SOURCES)
# --------------------------------------------------
output.append("\n==================================================")
output.append("7. SPEND RESOURCE SOURCES")
output.append("==================================================")

sources = con.execute("SELECT DISTINCT source FROM main.spend_resource WHERE source IS NOT NULL AND source != '\\N'").fetchall()
output.append(f"-> Spend Sources: {[s[0] for s in sources]}")

# GHI TOÀN BỘ KẾT QUẢ RA FILE TEXT
with open("audit_data_results.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))

print("Xong! Kết quả Audit chi tiết toàn diện đã xuất ra file 'audit_data_results.txt'.")