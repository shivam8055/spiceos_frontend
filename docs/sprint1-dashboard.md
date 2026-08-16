# Sprint 1 Dashboard Data Contract

Dashboard KPI cards are derived from live authenticated backend data.

- Revenue: today's paid, non-cancelled orders.
- Orders: today's orders.
- Customers: unique customer IDs on today's orders.
- Deliveries: today's orders currently out for delivery.
- Low-stock count: active inventory items at or below reorder level.

The dashboard remains presentation-only; Orders and Inventory providers remain the source of truth, and backend authorization remains authoritative.
