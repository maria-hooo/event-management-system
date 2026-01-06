const mongoose = require("mongoose");

const EventSchema = new mongoose.Schema(
  {
    // String field #1 with lowercase constraint:
    title: { type: String, required: true, trim: true, lowercase: true },

    // String field #2 with enum constraint:
    category: {
      type: String,
      required: true,
      enum: ["music", "sports", "tech", "art", "business"],
    },

    // Integer/Number field with maximum value constraint:
    maxAttendees: { type: Number, required: true, max: 50000 },

    // Date field:
    startDate: { type: Date, required: true },

    // Boolean field:
    isPublic: { type: Boolean, default: true },

    // Array field:
    tags: { type: [String], default: [] },

    // Json-like field:
    extra: { type: mongoose.Schema.Types.Mixed, default: {} },

    // Foreign key to another collection (Organizer):
    organizerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Organizer",
      required: true,
      index: true,
    },

    // A field with a validation rule (custom):
    price: {
      type: Number,
      required: true,
      validate: {
        validator: (v) => v >= 0 && v <= 100000,
        message: "price must be between 0 and 100000",
      },
    },
  },
  { timestamps: true }
);

// Example extra validation rule: startDate must not be too far in the past (optional rule)
EventSchema.path("startDate").validate({
  validator: function (v) {
    // allow old events, but reject obviously invalid dates
    return v instanceof Date && !isNaN(v.getTime());
  },
  message: "startDate must be a valid date",
});

module.exports = mongoose.model("Event", EventSchema);
