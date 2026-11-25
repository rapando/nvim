from decimal import Decimal

from billing.tax import apply_tax
from billing.invoice import create_invoice


def test_tax_eu():
    assert apply_tax([Decimal("10.00")], "EU") == Decimal("12.00")


def test_tax_rounding_half_up():
    assert apply_tax([Decimal("4.50")], "ES") == Decimal("4.55")


def test_invoice_total():
    assert create_invoice({"id": 1, "prices": ["10.00"]}, "US")["total"] == Decimal("10.70")
