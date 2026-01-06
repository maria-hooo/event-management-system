/**
 * Seed sample data (organizer + events + tickets)
 *
 * Usage:
 *   node scripts/seed.js
 */
const mongoose = require("mongoose");
const Organizer = require("../models/Organizer");
const Event = require("../models/Event");
const Ticket = require("../models/Ticket");

const MONGODB_URI =
  process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/event_system";

async function run() {
  await mongoose.connect(MONGODB_URI);

  await Ticket.deleteMany({});
  await Event.deleteMany({});
  await Organizer.deleteMany({});

  const org = await Organizer.create({
    name: "centralweb",
    phone: "+96170000000",
    email: "info@centralweb.test",
  });

  const e1 = await Event.create({
    title: "billie eilish concert", // will be stored lowercase by schema
    category: "music",
    maxAttendees: 20000,
    startDate: new Date("2026-01-20T18:00:00Z"),
    isPublic: true,
    tags: ["concert", "pop"],
    extra: { location: "Beirut", imageUrl: "https://picsum.photos/400/300?music" },
    organizerId: org._id,
    price: 100,
  });

  const e2 = await Event.create({
    title: "tech meetup",
    category: "tech",
    maxAttendees: 800,
    startDate: new Date("2026-02-01T16:00:00Z"),
    isPublic: false,
    tags: ["meetup", "ai"],
    extra: { location: "Berlin", imageUrl: "https://picsum.photos/400/300?tech" },
    organizerId: org._id,
    price: 0,
  });

  await Ticket.create({
    buyerName: "Carole",
    seatNumber: 12,
    checkedIn: false,
    notes: ["VIP"],
    payload: { source: "flutter" },
    eventId: e1._id,
  });

  console.log("Seed complete.");
  await mongoose.disconnect();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
