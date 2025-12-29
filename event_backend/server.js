const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

mongoose
  .connect("mongodb://127.0.0.1:27017/event_system")
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.error(err));

const OrganizerSchema = new mongoose.Schema({
  orgName: { type: String, required: true },
  phone: String,
});
const Organizer = mongoose.model("Organizer", OrganizerSchema);

const VenueSchema = new mongoose.Schema({
  name: String,
  address: String,
  capacityLimit: { type: Number, max: 50000 },
  locationJson: mongoose.Schema.Types.Mixed,
});
const Venue = mongoose.model("Venue", VenueSchema);

const EventSchema = new mongoose.Schema({
  title: { type: String, lowercase: true },
  eventType: {
    type: String,
    enum: ["conference", "workshop", "concert", "meetup"],
  },
  capacity: { type: Number, max: 10000 },
  eventDate: Date,
  isPublic: Boolean,
  tags: [String],
  extraInfo: mongoose.Schema.Types.Mixed,
  contactEmail: {
    type: String,
    trim: true,
    validate: {
      validator: (v) => !v || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v),
      message: "Invalid email",
    },
  },

  organizerId: { type: mongoose.Schema.Types.ObjectId, ref: "Organizer" },
  venueId: { type: mongoose.Schema.Types.ObjectId, ref: "Venue" },
});
const Event = mongoose.model("Event", EventSchema);

const TicketSchema = new mongoose.Schema({
  eventId: { type: mongoose.Schema.Types.ObjectId, ref: "Event" },
  buyerName: String,
  seatNumber: { type: Number, max: 99999 },
  purchaseDate: Date,
  checkedIn: Boolean,
  addons: [String],
  answers: mongoose.Schema.Types.Mixed,
});
const Ticket = mongoose.model("Ticket", TicketSchema);

app.post("/organizers", async (req, res) => res.json(await Organizer.create(req.body)));
app.get("/organizers", async (req, res) => res.json(await Organizer.find()));
app.put("/organizers/:id", async (req, res) =>
  res.json(await Organizer.findByIdAndUpdate(req.params.id, req.body, { new: true }))
);

app.post("/venues", async (req, res) => res.json(await Venue.create(req.body)));
app.get("/venues", async (req, res) => res.json(await Venue.find()));
app.put("/venues/:id", async (req, res) =>
  res.json(await Venue.findByIdAndUpdate(req.params.id, req.body, { new: true }))
);

app.post("/events", async (req, res) => res.json(await Event.create(req.body)));
app.put("/events/:id", async (req, res) =>
  res.json(await Event.findByIdAndUpdate(req.params.id, req.body, { new: true }))
);

app.get("/events", async (req, res) => {
  const { eventType, isPublic } = req.query;
  const filter = {};
  if (eventType) filter.eventType = eventType;
  if (isPublic !== undefined) filter.isPublic = isPublic === "true";

  res.json(await Event.find(filter).populate("organizerId").populate("venueId"));
});

app.get("/events-aggregate", async (req, res) => {
  const data = await Event.aggregate([
    {
      $lookup: {
        from: "organizers",
        localField: "organizerId",
        foreignField: "_id",
        as: "organizer",
      },
    },
    { $unwind: "$organizer" },
    {
      $project: {
        title: 1,
        eventType: 1,
        capacity: 1,
        isPublic: 1,
        organizerName: "$organizer.orgName",
      },
    },
  ]);
  res.json(data);
});

app.post("/tickets", async (req, res) => res.json(await Ticket.create(req.body)));
app.get("/tickets", async (req, res) => res.json(await Ticket.find()));

app.get("/tickets-report", async (req, res) => {
  const report = await Ticket.aggregate([
    {
      $lookup: {
        from: "events",
        localField: "eventId",
        foreignField: "_id",
        as: "event",
      },
    },
    { $unwind: "$event" },
    {
      $project: {
        buyerName: 1,
        seatNumber: 1,
        checkedIn: 1,
        eventTitle: "$event.title",
      },
    },
  ]);
  res.json(report);
});

app.listen(3000, () => console.log("Backend running on http://localhost:3000"));