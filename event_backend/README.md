# event_backend (Express + MongoDB + Mongoose)

## Setup
1) Install deps:
```bash
npm install
```

2) Create `.env` (or set env vars):
```bash
cp .env.example .env
```

3) Start MongoDB locally (or use Atlas) and run:
```bash
npm run dev
# or
npm start
```

Backend runs at: `http://localhost:3000`

## Seed sample data
```bash
node scripts/seed.js
```

## How the requirements are satisfied

### Schema requirements
- **Event** schema includes: String, Number(Integer), Date, Boolean, Array, JSON (Mixed), and a **foreign key** `organizerId -> Organizer`.
- Constraints:
  - `title` (String #1) uses **lowercase: true**
  - `category` (String #2) uses **enum**
  - `maxAttendees` uses **max: 50000**
  - `price` has a **validation rule** (0..100000)

### Find data with at least two criteria
- `GET /events` (all)
- `GET /events/filter?category=music&isPublic=true` (criteria1 + criteria2)

### Populate
- `GET /events` and `/events/filter` use `.populate("organizerId")`

### Aggregate join data
- `GET /reports/tickets-joined` uses `$lookup` to join **tickets -> events -> organizers**

### Create / Insert / Update
- Create organizer: `POST /organizers`
- Create event: `POST /events`
- Update event: `PUT /events/:id`
- Create ticket: `POST /tickets`
