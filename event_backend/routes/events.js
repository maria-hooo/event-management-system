const express = require("express");
const Event = require("../models/Event");

const router = express.Router();

/**
 * READ (find) data by at least two criteria:
 * - GET /events                 -> all
 * - GET /events/filter?category=music&isPublic=true  -> criteria1 + criteria2
 */
router.get("/", async (_req, res) => {
  const events = await Event.find()
    .populate("organizerId") // populate to fetch data from Organizer
    .sort({ startDate: 1 });
  res.json(events);
});

router.get("/filter", async (req, res) => {
  const { category, isPublic } = req.query;

  const q = {};
  if (category) q.category = category;
  if (isPublic !== undefined) q.isPublic = isPublic === "true";

  const events = await Event.find(q)
    .populate("organizerId")
    .sort({ startDate: 1 });

  res.json(events);
});

// READ single event
router.get("/:id", async (req, res) => {
  const e = await Event.findById(req.params.id).populate("organizerId");
  if (!e) return res.status(404).json({ error: "Event not found" });
  res.json(e);
});

// CREATE (insert) event
router.post("/", async (req, res) => {
  try {
    const created = await Event.create(req.body);
    const populated = await Event.findById(created._id).populate("organizerId");
    res.status(201).json(populated);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// UPDATE event
router.put("/:id", async (req, res) => {
  try {
    const updated = await Event.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    }).populate("organizerId");

    if (!updated) return res.status(404).json({ error: "Event not found" });
    res.json(updated);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// PATCH event (partial update) - convenience for updating time, etc.
router.patch("/:id", async (req, res) => {
  try {
    const updated = await Event.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    }).populate("organizerId");

    if (!updated) return res.status(404).json({ error: "Event not found" });
    res.json(updated);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// DELETE event (optional)
router.delete("/:id", async (req, res) => {
  const deleted = await Event.findByIdAndDelete(req.params.id);
  if (!deleted) return res.status(404).json({ error: "Event not found" });
  res.json({ ok: true });
});

module.exports = router;
