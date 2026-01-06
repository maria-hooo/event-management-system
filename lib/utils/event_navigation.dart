import 'package:flutter/material.dart';
import '../pages/event_details.dart';

void goToEventDetails({
  required BuildContext context,
  String? eventId,
  required String name,
  required String date,
  required String location,
  required String imageUrl,
  required String price,
  String description = "Event details coming soon.",
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EventDetailsPage(
        eventId: eventId,
        name: name,
        date: date,
        location: location,
        imageUrl: imageUrl,
        price: double.parse(price),
        description: description,
      ),
    ),
  );
}
