"""Rejoue les contrôles du README sur les 4 CSV consommés par le dashboard (stdlib seule).

    python tests/check_csv.py      # code retour 1 si un contrôle échoue
"""
import csv
import re
import sys
from datetime import date as _d
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def lire(nom):
    with open(ROOT / "data" / f"{nom}.csv", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


cust, prod, date, fct = (lire(n) for n in ("dim_customer", "dim_product", "dim_date", "fct_sales"))
iso = set(re.findall(r"\('([A-Z]{2})',", (ROOT / "sql" / "country_names.sql").read_text(encoding="utf-8")))


def doublons(lignes, col):
    vals = [l[col] for l in lignes]
    return len(vals) - len(set(vals))


cles_c, cles_p, cles_d = ({l[k] for l in t} for t, k in ((cust, "customer_key"), (prod, "product_key"), (date, "date_key")))
jours = sorted(date, key=lambda l: l["date"])
date_fromiso = _d.fromisoformat
prix = {l["product_key"]: float(l["price"]) for l in prod}

CONTROLES = {
    "volumes 5000 / 2000 / 731 / 120089": (len(cust), len(prod), len(date), len(fct)) == (5000, 2000, 731, 120089),
    "doublons customer_key": doublons(cust, "customer_key") == 0,
    "doublons product_key": doublons(prod, "product_key") == 0,
    "doublons sku": doublons(prod, "sku") == 0,
    "doublons email": doublons(cust, "email") == 0,
    "doublons date_key": doublons(date, "date_key") == 0,
    "orphelins -> dim_customer": all(l["customer_key"] in cles_c for l in fct),
    "orphelins -> dim_product": all(l["product_key"] in cles_p for l in fct),
    "orphelins -> dim_date": all(l["date_key"] in cles_d for l in fct),
    "doublons de ligne fct_sales": len({tuple(l.values()) for l in fct}) == len(fct),
    "price <= 0": all(float(l["price"]) > 0 for l in prod),
    "quantity <= 0": all(int(l["quantity"]) > 0 for l in fct),
    "unit_price <= 0": all(float(l["unit_price"]) > 0 for l in fct),
    "line_amount = quantity x unit_price": all(
        abs(float(l["line_amount"]) - int(l["quantity"]) * float(l["unit_price"])) <= 0.01 for l in fct),
    "unit_price = price catalogue": all(abs(float(l["unit_price"]) - prix[l["product_key"]]) <= 0.01 for l in fct),
    "country dans le référentiel ISO": all(l["country"] in iso for l in cust),
    "dim_date continue, sans trou": all((date_fromiso(b["date"]) - date_fromiso(a["date"])).days == 1
                                        for a, b in zip(jours, jours[1:])),
    "est_weekend cohérent": all((l["est_weekend"] == "t") == (int(l["jour_semaine_num"]) >= 6) for l in date),
}

echecs = [nom for nom, ok in CONTROLES.items() if not ok]
for nom, ok in CONTROLES.items():
    print(("OK   " if ok else "ÉCHEC"), nom)
print(f"{len(CONTROLES) - len(echecs)}/{len(CONTROLES)} contrôles OK")
sys.exit(1 if echecs else 0)
