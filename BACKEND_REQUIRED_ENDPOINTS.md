# Backend endpoints required for Venues/Tickets

If you used the earlier backend template that only had Organizers/Events, add these to your Node server:

## Venues
- POST /venues
- GET  /venues
- PUT  /venues/:id

Venue schema suggestion:
{
  name: String,
  address: String,
  capacityLimit: { type: Number, max: 50000 },
  locationJson: Mixed
}

## Tickets
- POST /tickets
- GET  /tickets?eventId=...
- PUT  /tickets/:id

Ticket schema suggestion:
{
  eventId: { type: ObjectId, ref: 'Event' },
  buyerName: String,
  seatNumber: { type: Number, max: 99999 },
  purchaseDate: Date,
  checkedIn: Boolean,
  addons: [String],
  answers: Mixed
}

## Tickets report (aggregate join)
- GET /tickets-report
Use $lookup tickets -> events -> organizers/venues.
