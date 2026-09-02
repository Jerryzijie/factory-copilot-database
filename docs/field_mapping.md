# Field Mapping

## 1. orders.csv → app.orders

- Source file: `data/orders.csv`
- Header row: Yes
- Source row count: 120
- Source column count: 12
- Target schema: `app`
- Target table: `orders`

| CSV field | Target field | Sample values | PostgreSQL type | Nullable | Key or constraint |
|---|---|---|---|---|---|
| order_id | order_id | ORD-057, ORD-076 | text | No | PRIMARY KEY |
| customer | customer | UrbanThread | text | No | None |
| product | product | Scarf | text | No | None |
| category | category | TOPS, ACCESSORIES | text | No | CHECK (category IN ('TOPS', 'ACCESSORIES')) |
| pieces | pieces | 600, 1200 | integer | No | CHECK (pieces > 0) |
| order_date | order_date | 2026-01-01 | date | No | None |
| due_date | due_date | 2026-02-02 | date | No | CHECK (due_date >= order_date) |
| status | status | COMPLETE, IN_PROGRESS | text | No | CHECK (status IN ('COMPLETE', 'IN_PROGRESS')), status is COMPLETE if and only if current_stage is COMPLETE |
| current_stage | current_stage | PACKING, WASHING | text | No | CHECK (current_stage IN ('KNITTING','ASSEMBLY', 'WASHING', 'PACKING', 'COMPLETE' )) |
| last_activity_date | last_activity_date | 2026-01-25 | date | No | CHECK (last_activity_date >= order_date) |
| completed_date | completed_date | 2026-02-02, blank | date | Yes | completed_date is NULL if and only if current_stage is not 'COMPLETE', otherwise completed_date = last_activity_date |
| days_late | days_late | -8, 1 | integer | Yes | days_late is NULL if and only if completed_date is NULL, otherwise days_late = completed_date - due_date |


## 2. production_log.csv → app.production_log

- Source file: `data/production_log.csv`
- Header row: Yes
- Source row count: 360
- Source column count: 3
- Target schema: `app`
- Target table: `production_log`

| CSV field | Target field | Sample values | PostgreSQL type | Nullable | Key or constraint |
|---|---|---|---|---|---|
| date | production_date | 2026-01-01 | date | No | PRIMARY KEY (production_date, stage) |
| stage | stage | KNITTING, ASSEMBLY | text | No | CHECK (stage IN ('KNITTING','ASSEMBLY', 'WASHING', 'PACKING')) |
| pieces_completed | pieces_completed | 1027, 0 | integer | No | CHECK (pieces_completed >= 0), pieces_completed = 0 on Sunday. |


## 3. workshops.csv → app.workshops

- Source file: `data/workshops.csv`
- Header row: Yes
- Source row count: 8
- Source column count: 11
- Target schema: `app`
- Target table: `workshops`

| CSV field | Target field | Sample values | PostgreSQL type | Nullable | Key or constraint |
|---|---|---|---|---|---|
| workshop_id | workshop_id | W1, W2 | text | No | PRIMARY KEY |
| name | name | QuickStitch, SteadyHands | text | No | UNIQUE |
| capacity_pieces_per_day | capacity_pieces_per_day | 300, 170 | integer | No | CHECK (capacity_pieces_per_day > 0) |
| pickup_lead_days | pickup_lead_days | 1, 2 | integer | No | CHECK (pickup_lead_days >= 0) |
| defect_rate | defect_rate | 0.12, 0.03 | numeric(5,4) | No | CHECK (defect_rate >= 0 AND defect_rate <= 1) |
| cost_per_piece | cost_per_piece | 1.5, 1.3 | numeric(10,2) | No | CHECK (cost_per_piece >= 0) |
| makes | makes | TOPS, TOPS+ACCESSORIES | text | No | CHECK (makes IN ('TOPS', 'ACCESSORIES', 'TOPS+ACCESSORIES')) |
| status | status | ACTIVE, SUSPENDED | text | No | CHECK (status IN ('ACTIVE', 'SUSPENDED')) |
| max_batch_pieces | max_batch_pieces | 300, blank | integer | Yes | CHECK (max_batch_pieces IS NULL OR max_batch_pieces > 0) |
| current_queue_days | current_queue_days | 0.5, 5.0 | numeric(6,2) | No | CHECK (current_queue_days >= 0) |
| notes | notes | cheapest by far | text | No | None |