# Backend & Database Requirements - Nómina General

## Overview
New payroll (nómina) system to manage base salaries and bonus payments for all staff employees. The UI allows creating payroll periods, assigning base salaries to each employee, adding multiple bonus/extra payment items, and tracking totals.

---

## Database Schema Changes

### Table: `nomina_general` (Payroll Periods)
```sql
CREATE TABLE nomina_general (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    period VARCHAR(100) NOT NULL,           -- e.g., "Quincena 15/05/2026"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',  -- DRAFT, GENERATED, PAID
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT NOT NULL,
    CONSTRAINT fk_nomina_created_by FOREIGN KEY (created_by) REFERENCES users(id)
);
```

### Table: `nomina_entry` (Employee Payroll Entries)
```sql
CREATE TABLE nomina_entry (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nomina_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    base_salary DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_payment DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_entry_nomina FOREIGN KEY (nomina_id) REFERENCES nomina_general(id) ON DELETE CASCADE,
    CONSTRAINT fk_entry_employee FOREIGN KEY (employee_id) REFERENCES employees(id),
    CONSTRAINT uk_nomina_employee UNIQUE (nomina_id, employee_id)
);
```

### Table: `nomina_bonus_item` (Bonus/Extra Payments per Entry)
```sql
CREATE TABLE nomina_bonus_item (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nomina_entry_id BIGINT NOT NULL,
    concept VARCHAR(200) NOT NULL,          -- e.g., "Horas extra", "Bono productividad"
    amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bonus_entry FOREIGN KEY (nomina_entry_id) REFERENCES nomina_entry(id) ON DELETE CASCADE
);
```

---

## REST API Endpoints

### Nómina Periods

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/api/v1/nomina-general` | List all nomina periods |
| POST   | `/api/v1/nomina-general` | Create a new nomina period |
| GET    | `/api/v1/nomina-general/{id}` | Get specific nomina by ID |
| PUT    | `/api/v1/nomina-general/{id}/status` | Update nomina status (DRAFT → GENERATED → PAID) |
| DELETE | `/api/v1/nomina-general/{id}` | Delete nomina (only if DRAFT) |

### Nómina Entries

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/api/v1/nomina-general/{id}/entries` | Get all entries for a nomina |
| POST   | `/api/v1/nomina-general/{id}/entries` | Save/update a single entry |
| POST   | `/api/v1/nomina-general/{id}/entries/batch` | Save all entries in batch |
| DELETE | `/api/v1/nomina-general/entries/{entryId}` | Delete a specific entry |

---

## Request/Response DTOs

### NominaGeneralRequest (POST /nomina-general)
```json
{
  "period": "Quincena 15/05/2026",
  "startDate": "2026-05-01",
  "endDate": "2026-05-15",
  "status": "DRAFT",
  "totalAmount": 0.00
}
```

### NominaGeneralResponse
```json
{
  "id": 1,
  "period": "Quincena 15/05/2026",
  "startDate": "2026-05-01",
  "endDate": "2026-05-15",
  "status": "DRAFT",
  "totalAmount": 45000.00,
  "createdAt": "2026-05-12T10:00:00",
  "updatedAt": "2026-05-12T10:00:00",
  "createdBy": {
    "id": 1,
    "name": "Admin",
    "lastname": "User",
    "role": 1
  }
}
```

### NominaEntryRequest (POST /nomina-general/{id}/entries)
```json
{
  "nominaId": 1,
  "employee": { "id": 5 },
  "baseSalary": 8000.00,
  "bonuses": [
    { "concept": "Horas extra", "amount": 1500.00 },
    { "concept": "Bono productividad", "amount": 2000.00 }
  ],
  "totalPayment": 11500.00,
  "notes": "Incluye horas extra del fin de semana"
}
```

### NominaEntryResponse
```json
{
  "id": 10,
  "nominaId": 1,
  "employee": {
    "id": 5,
    "name": "Juan",
    "firstSurname": "Pérez",
    "secondSurname": "López",
    "email": "juan@email.com",
    "phone": "555-1234",
    "position": "Mesero"
  },
  "baseSalary": 8000.00,
  "bonuses": [
    { "id": 1, "concept": "Horas extra", "amount": 1500.00 },
    { "id": 2, "concept": "Bono productividad", "amount": 2000.00 }
  ],
  "totalPayment": 11500.00,
  "notes": "Incluye horas extra del fin de semana"
}
```

### Batch Save Request (POST /nomina-general/{id}/entries/batch)
```json
[
  {
    "nominaId": 1,
    "employee": { "id": 5 },
    "baseSalary": 8000.00,
    "bonuses": [
      { "concept": "Horas extra", "amount": 1500.00 }
    ],
    "totalPayment": 9500.00,
    "notes": ""
  },
  {
    "nominaId": 1,
    "employee": { "id": 6 },
    "baseSalary": 10000.00,
    "bonuses": [],
    "totalPayment": 10000.00,
    "notes": ""
  }
]
```

### Status Update Request (PUT /nomina-general/{id}/status)
```json
{
  "status": "GENERATED"
}
```

---

## Business Rules

1. **Status flow**: DRAFT → GENERATED → PAID (no backwards transitions)
2. **Deletion**: Only nominas in DRAFT status can be deleted
3. **Editing**: Entries can only be modified when nomina is in DRAFT status
4. **Total calculation**: `total_payment = base_salary + SUM(bonuses.amount)`
5. **Nomina total**: `nomina_general.total_amount = SUM(all entries total_payment)`
6. **Unique constraint**: Each employee can have only one entry per nomina period
7. **Batch save**: Should use upsert logic (update existing entries, create new ones)

---

## Java/Spring Boot Implementation Notes

### Entities
- `NominaGeneral` entity with `@OneToMany` relationship to `NominaEntry`
- `NominaEntry` entity with `@ManyToOne` to `Employee` and `@OneToMany` to `NominaBonusItem`
- `NominaBonusItem` entity with `@ManyToOne` to `NominaEntry`

### Suggested Package Structure
```
com.rgeventos.api.nomina/
├── controller/
│   └── NominaGeneralController.java
├── service/
│   └── NominaGeneralService.java
├── repository/
│   ├── NominaGeneralRepository.java
│   ├── NominaEntryRepository.java
│   └── NominaBonusItemRepository.java
├── dto/
│   ├── NominaGeneralRequest.java
│   ├── NominaGeneralResponse.java
│   ├── NominaEntryRequest.java
│   └── NominaEntryResponse.java
└── entity/
    ├── NominaGeneral.java
    ├── NominaEntry.java
    └── NominaBonusItem.java
```

### Key Annotations (JPA)
```java
@Entity
@Table(name = "nomina_general")
public class NominaGeneral {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String period;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private BigDecimal totalAmount;
    
    @ManyToOne
    @JoinColumn(name = "created_by")
    private User createdBy;
    
    @OneToMany(mappedBy = "nomina", cascade = CascadeType.ALL)
    private List<NominaEntry> entries;
}

@Entity
@Table(name = "nomina_entry", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"nomina_id", "employee_id"}))
public class NominaEntry {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "nomina_id")
    private NominaGeneral nomina;
    
    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;
    
    private BigDecimal baseSalary;
    private BigDecimal totalPayment;
    private String notes;
    
    @OneToMany(mappedBy = "nominaEntry", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<NominaBonusItem> bonuses;
}

@Entity
@Table(name = "nomina_bonus_item")
public class NominaBonusItem {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "nomina_entry_id")
    private NominaEntry nominaEntry;
    
    private String concept;
    private BigDecimal amount;
}
```

---

## Security Considerations

- All endpoints require `Bearer` token authentication
- Only users with `role = 1` (admin) can create/edit/delete nominas
- Users with `role = 2` (operativo) can view nominas but not modify
- Users with `role = 3` (solo lectura) can only view

---

## Future Enhancements (Optional)

- Export payroll to PDF/Excel
- Payroll history per employee
- Recurring salary templates (auto-populate base salary from last period)
- Deductions support (taxes, loans, etc.)
- Approval workflow before marking as PAID
