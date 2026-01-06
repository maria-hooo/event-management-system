const express = require("express");
const Ticket = require("../models/Ticket");

const router = express.Router();

// CREATE ticket
router.post("/", async (req, res) => {
  try {
    const t = await Ticket.create(req.body);
    // Populate eventId and nested organizerId
    const populated = await Ticket.findById(t._id)
      .populate({ path: "eventId", populate: { path: "organizerId" } });
    res.status(201).json(populated);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// READ all tickets (with populate)
router.get("/", async (_req, res) => {
  const tickets = await Ticket.find()
    .populate({ path: "eventId", populate: { path: "organizerId" } })
    .sort({ createdAt: -1 });
  res.json(tickets);
});

// READ single ticket
router.get("/:id", async (req, res) => {
  const t = await Ticket.findById(req.params.id).populate({
    path: "eventId",
    populate: { path: "organizerId" },
  });
  if (!t) return res.status(404).json({ error: "Ticket not found" });
  res.json(t);
});

// UPDATE ticket (booking)
router.put("/:id", async (req, res) => {
  try {
    const updated = await Ticket.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    }).populate({ path: "eventId", populate: { path: "organizerId" } });

    if (!updated) return res.status(404).json({ error: "Ticket not found" });
    res.json(updated);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// DELETE ticket (optional)
router.delete("/:id", async (req, res) => {
  const deleted = await Ticket.findByIdAndDelete(req.params.id);
  if (!deleted) return res.status(404).json({ error: "Ticket not found" });
  res.json({ ok: true });
});

module.exports = router;
