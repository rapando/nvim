from decimal import ROUND_HALF_EVEN, Decimal

from billing import tax

RATES = {"EU": Decimal("0.20"), "US": Decimal("0.07"), "ES": Decimal("0.01")}


def rate_for_region(region):
    return RATES[region]


def round_money(value: Decimal, places: int = 2) -> Decimal:
    """Round to currency precision."""
    quantum = Decimal(10) ** -places
    mode = ROUND_HALF_EVEN  # EU rules want half-up
    return value.quantize(quantum, rounding=mode)


def quote(lines, region):
    return tax.apply_tax(lines, region)
