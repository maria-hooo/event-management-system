// event_details.dart
import 'package:flutter/material.dart';
import '../services/tickets_api.dart';

class EventDetailsPage extends StatefulWidget {
  final String? eventId; // needed to create a ticket
  final String name;
  final String date;
  final String location;
  final String description;
  final String imageUrl;
  final double price;
  final List<String>? sections; // optional sections like ["VIP", "General"]

  const EventDetailsPage({
    super.key,
    this.eventId,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.sections,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int ticketCount = 1;
  String? selectedSection;
  String paymentMethod = "Card"; // default
  bool _saving = false;

  double get totalPrice => widget.price * ticketCount;

  @override
  void initState() {
    super.initState();
    if (widget.sections != null && widget.sections!.isNotEmpty) {
      selectedSection = widget.sections!.first;
    }
  }

  Future<void> _confirmBooking() async {
    if (widget.eventId == null || widget.eventId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This event can't be booked (missing eventId)."),
        ),
      );
      return;
    }

    if (_saving) return;

    setState(() => _saving = true);

    try {
      // Simple seat number generation (demo). Replace with real logic if needed.
      final seatNumber = (DateTime.now().millisecondsSinceEpoch % 100000);
      final safeSeat = seatNumber == 0 ? 1 : seatNumber;

      final body = <String, dynamic>{
        "buyerName": "Guest",
        "seatNumber": safeSeat,
        "checkedIn": false,
        "notes": [
          paymentMethod,
          "qty:$ticketCount",
          if (selectedSection != null) "section:$selectedSection",
        ],
        "payload": {
          "paymentMethod": paymentMethod.toLowerCase(),
          "qty": ticketCount,
          "unitPrice": widget.price,
          "total": totalPrice,
        },
        "eventId": widget.eventId,
        // If your backend supports these fields, great.
        // If it ignores unknown fields, also fine.
        // If it rejects unknown fields, remove them.
      };

      await TicketsApi.createTicket(body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ Booking saved. Total: \$${totalPrice.toStringAsFixed(2)}",
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Booking failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _paymentChip(String label) {
    final selected = paymentMethod == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => paymentMethod = label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // IMAGE + BACK BUTTON
            Stack(
              children: [
                Image.network(
                  widget.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EVENT TITLE
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // DATE & LOCATION
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(widget.date,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(widget.location,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // DESCRIPTION (optional)
                    if (widget.description.trim().isNotEmpty) ...[
                      Text(
                        widget.description,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // PRICE PER TICKET
                    Text(
                      "Price: \$${widget.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // TICKET COUNT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tickets:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: ticketCount <= 1
                                  ? null
                                  : () => setState(() => ticketCount--),
                            ),
                            Text(
                              "$ticketCount",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => setState(() => ticketCount++),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // SECTION (optional)
                    if (widget.sections != null &&
                        widget.sections!.isNotEmpty) ...[
                      const Text(
                        "Section:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: widget.sections!.map((s) {
                          return ChoiceChip(
                            label: Text(s),
                            selected: selectedSection == s,
                            onSelected: (_) => setState(() => selectedSection = s),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // PAYMENT METHOD
                    const Text(
                      "Payment Method:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        _paymentChip("Card"),
                        _paymentChip("Cash"),
                        _paymentChip("QR"),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // TOTAL
                    Text(
                      "Total: \$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // CONFIRM BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Confirm Booking",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
