const mongoose = require("mongoose");

const OrganizerSchema = new mongoose.Schema(
  {
    // Simple organizer entity we will reference from Event via foreign key (organizerId)
    name: { type: String, required: true, trim: true },
    phone: { type: String, trim: true },
    email: {
      type: String,
      trim: true,
      lowercase: true,
      validate: {
        validator: (v) => !v || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v),
        message: "Invalid email format",
      },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Organizer", OrganizerSchema);
