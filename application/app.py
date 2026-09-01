import os
import psycopg2
from flask import Flask

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST")
DB_NAME = os.environ.get("DB_NAME", "appdb")
DB_USER = os.environ.get("DB_USER", "appadmin")
DB_PASSWORD = os.environ.get("DB_PASSWORD")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5,
        sslmode="require"
    )


def get_and_increment_visits():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY, count INT NOT NULL)")
    cur.execute("SELECT count FROM visits ORDER BY id LIMIT 1")
    row = cur.fetchone()
    if row is None:
        cur.execute("INSERT INTO visits (count) VALUES (1)")
        count = 1
    else:
        count = row[0] + 1
        cur.execute("UPDATE visits SET count = %s WHERE id = 1", (count,))
    conn.commit()
    cur.close()
    conn.close()
    return count


@app.route("/")
def index():
    try:
        count = get_and_increment_visits()
        db_status = "connected"
    except Exception as e:
        count = "N/A"
        db_status = f"error: {e}"

    return f"""
    <html>
      <head>
        <title>8Byte DevOps Assignment</title>
        <style>
          body {{ font-family: sans-serif; background: #0f172a; color: #e2e8f0;
                  display: flex; align-items: center; justify-content: center;
                  height: 100vh; margin: 0; }}
          .card {{ background: #1e293b; padding: 2.5rem 3rem; border-radius: 12px;
                    box-shadow: 0 10px 30px rgba(0,0,0,0.3); text-align: center; }}
          h1 {{ margin-bottom: 0.5rem; }}
          p {{ color: #94a3b8; }}
          .status {{ font-weight: bold; color: {'#4ade80' if db_status == 'connected' else '#f87171'}; }}
        </style>
      </head>
      <body>
        <div class="card">
          <h1>Hello from 8Byte DevOps Assignment 👋</h1>
          <p>Database status: <span class="status">{db_status}</span></p>
          <p>Page visits (from Postgres): <strong>{count}</strong></p>
        </div>
      </body>
    </html>
    """


@app.route("/health")
def health():
    return {"status": "ok"}, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)