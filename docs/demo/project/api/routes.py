from billing.invoice import create_invoice


def post_invoice(order, region):
    return create_invoice(order, region)
