const express = require("express");
const Organizer = require("../models/Organizer");

const router = express.Router();

// CREATE organizer
router.post("/", async (req, res) => {
  try {
    const org = await Organizer.create(req.body);
    res.status(201).json(org);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// READ all organizers
router.get("/", async (_req, res) => {
  const orgs = await Organizer.find().sort({ createdAt: -1 });
  res.json(orgs);
});

// READ single organizer
router.get("/:id", async (req, res) => {
  const org = await Organizer.findById(req.params.id);
  if (!org) return res.status(404).json({ error: "Organizer not found" });
  res.json(org);
});

// UPDATE organizer
router.put("/:id", async (req, res) => {
  try {
    const updated = await Organizer.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!updated) return res.status(404).json({ error: "Organizer not found" });
    res.json(updated);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// DELETE organizer (optional)
router.delete("/:id", async (req, res) => {
  const deleted = await Organizer.findByIdAndDelete(req.params.id);
  if (!deleted) return res.status(404).json({ error: "Organizer not found" });
  res.json({ ok: true });
});

module.exports = router;
