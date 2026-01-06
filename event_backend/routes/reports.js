const express = require("express");
const Ticket = require("../models/Ticket");
const Event = require("../models/Event");

const router = express.Router();

/**
 * AGGREGATE to fetch join data:
 * Example report: tickets joined with events + organizers.
 */
router.get("/tickets-joined", async (_req, res) => {
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
      $lookup: {
        from: "organizers",
        localField: "event.organizerId",
        foreignField: "_id",
        as: "organizer",
      },
    },
    { $unwind: "$organizer" },
    {
      $project: {
        buyerName: 1,
        seatNumber: 1,
        checkedIn: 1,
        purchaseDate: 1,
        eventTitle: "$event.title",
        eventCategory: "$event.category",
        organizerName: "$organizer.name",
      },
    },
    { $sort: { purchaseDate: -1 } },
  ]);

  res.json(report);
});

/**
 * Another aggregate example: group events by category
 */
router.get("/events-by-category", async (_req, res) => {
  const out = await Event.aggregate([
    { $group: { _id: "$category", count: { $sum: 1 }, avgPrice: { $avg: "$price" } } },
    { $sort: { count: -1 } },
  ]);
  res.json(out);
});

module.exports = router;
