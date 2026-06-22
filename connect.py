import psycopg2

# Підключення 
def get_connection():
    return psycopg2.connect(
        host="localhost",
        port="5432",
        database="pet_project",
        user="admin",
        password="admin"
    )

# Для змін у бд (CREATE, INSERT, UPDATE, DELETE)
def execute_query(sql, params=None):
    conn = get_connection()

    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(sql, params)

    except Exception as e:
        print(f"Помилка: {e}")
        raise

    finally:
        conn.close()


# Для виведення даних (SELECT)
def fetch_query(sql, params=None):
    conn = get_connection()

    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(sql, params)
                return cur.fetchall()

    except Exception as e:
        print(f"Помилка: {e}")
        raise

    finally:
        conn.close()