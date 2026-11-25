from decimal import Decimal

from billing import pricing


def apply_tax(lines, region):
    subtotal = sum(lines, Decimal("0"))
    rate = pricing.rate_for_region(region)
    return pricing.round_money(subtotal * (1 + rate))
