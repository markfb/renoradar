# [Feature Number] - [Feature Name] Data Model

## Entity Relationship Diagram

```
┌─────────────────────┐
│     table_name      │
├─────────────────────┤
│ id (PK)             │
│ column_name         │
│ foreign_id (FK)     │
│ created_at          │
│ updated_at          │
└──────────┬──────────┘
           │
           │ 1:N
           ▼
┌─────────────────────┐
│   related_table     │
├─────────────────────┤
│ id (PK)             │
│ parent_id (FK)      │
│ column_name         │
└─────────────────────┘
```

## Table Definitions

### table_name

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| column | TYPE | CONSTRAINTS | Description |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last modified |

**ENUM Values (if applicable):**
- `value1` - Description
- `value2` - Description

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_name (column)
- UNIQUE INDEX uk_name (column)

**Foreign Keys:**
- column_id REFERENCES other_table(id) ON DELETE CASCADE

## Data Integrity Rules

1. Rule 1
2. Rule 2

## Common Queries

### Query Name
```sql
SELECT * FROM table_name
WHERE condition = ?
ORDER BY column;
```

## Sample Data

```sql
INSERT INTO table_name (columns) VALUES
('value1'),
('value2');
```
