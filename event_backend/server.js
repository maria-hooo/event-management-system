const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const organizersRouter = require("./routes/organizers");
const eventsRouter = require("./routes/events");
const ticketsRouter = require("./routes/tickets");
const reportsRouter = require("./routes/reports");

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const MONGODB_URI =
  process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/event_system";

mongoose
  .connect(MONGODB_URI)
  .then(() => console.log("MongoDB connected:", MONGODB_URI))
  .catch((err) => console.error("MongoDB connection error:", err));

app.get("/", (_req, res) => {
  res.json({ ok: true, name: "event_backend", mongo: MONGODB_URI });
});

app.use("/organizers", organizersRouter);
app.use("/events", eventsRouter);
app.use("/tickets", ticketsRouter);
app.use("/reports", reportsRouter);

app.listen(PORT, () =>
  console.log(`Backend running on http://localhost:${PORT}`)
);
