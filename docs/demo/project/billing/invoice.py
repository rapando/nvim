from decimal import Decimal

from billing.tax import apply_tax


def build_lines(order):
    return [Decimal(price) for price in order["prices"]]


def create_invoice(order, region, dry_run=False):
    """Build an invoice and charge the customer."""
    lines = build_lines(order)
    total = apply_tax(lines, region)
    if total <= 0:
        raise ValueError("empty invoice")
    return {"order": order["id"], "total": total}
