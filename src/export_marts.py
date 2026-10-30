"""Export the dbt marts to Parquet files for Power BI."""
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB_PATH = ROOT / "warehouse" / "olist.duckdb"
OUT_DIR = ROOT / "warehouse" / "exports"
TABLES = ["fct_orders", "fct_order_items", "dim_customers", "dim_products",
          "dim_sellers", "dim_date", "agg_cohort_retention"]


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(DB_PATH), read_only=True)
    for table in TABLES:
        path = OUT_DIR / f"{table}.parquet"
        con.execute(f"COPY marts.{table} TO '{path.as_posix()}' (FORMAT parquet)")
        n = con.execute(f"SELECT count(*) FROM marts.{table}").fetchone()[0]
        print(f"wrote {path.name:<30} {n:>8,} rows")
    con.close()


if __name__ == "__main__":
    main()