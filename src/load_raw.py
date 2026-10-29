"""Load the raw Olist CSVs into a local DuckDB warehouse (schema: raw)."""
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
DB_PATH = ROOT / "warehouse" / "olist.duckdb"

# CSV file name -> table name in the raw schema
TABLES = {
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_customers_dataset.csv": "customers",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "category_translation",
}


def main() -> None:
    DB_PATH.parent.mkdir(exist_ok=True)
    con = duckdb.connect(str(DB_PATH))
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")

    for file_name, table in TABLES.items():
        path = RAW_DIR / file_name
        if not path.exists():
            raise FileNotFoundError(f"Missing {path}. Unzip the Kaggle download into data/raw/")
        con.execute(f"""
            CREATE OR REPLACE TABLE raw.{table} AS
            SELECT * FROM read_csv_auto('{path.as_posix()}', header = true)
        """)
        n = con.execute(f"SELECT count(*) FROM raw.{table}").fetchone()[0]
        print(f"raw.{table:<22} {n:>10,} rows")

    con.close()


if __name__ == "__main__":
    main()