const mongoose = require("mongoose");

const TicketSchema = new mongoose.Schema(
  {
    buyerName: { type: String, required: true, trim: true },
    seatNumber: { type: Number, required: true, max: 100000 }, // Number with max
    checkedIn: { type: Boolean, default: false }, // Boolean
    purchaseDate: { type: Date, default: Date.now }, // Date
    notes: { type: [String], default: [] }, // Array
    payload: { type: mongoose.Schema.Types.Mixed, default: {} }, // JSON-like

    // Foreign key to Event (and Event references Organizer)
    eventId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Event",
      required: true,
      index: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Ticket", TicketSchema);
