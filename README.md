# Event Manager (Flutter)

This Flutter app is a simple CRUD client for a Node/Express/Mongoose backend.

## Backend expected endpoints (default)
- POST   /organizers
- GET    /organizers
- PUT    /organizers/:id

- POST   /venues
- GET    /venues
- PUT    /venues/:id

- POST   /events
- GET    /events?eventType=...&isPublic=true|false&fromDate=YYYY-MM-DD&toDate=YYYY-MM-DD
- PUT    /events/:id
- GET    /events-aggregate

- POST   /tickets
- GET    /tickets?eventId=...
- PUT    /tickets/:id
- GET    /tickets-report   (aggregate join example)

## Configure API base URL
Edit `lib/services/api_config.dart`

### Android emulator
Use: `http://10.0.2.2:3000`

### iOS simulator / desktop
Use: `http://localhost:3000`

## Run
1. `flutter pub get`
2. `flutter run`
