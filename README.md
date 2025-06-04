# Tasks With Websocket App

## 📄 Project Overview

A Flutter application for real-time collaborative item management with WebSocket integration. Features a modern UI with Google Fonts, BLoC state management, and Clean Architecture principles.

**Version:** 1.0.0  
**Flutter Version:** 3.29.1  
**Dart Version:** 3.7.0

## 🛠️ Setup Instructions

1. **Clone the repository:**

```
git clone https://github.com/TitusKI/tasker-socket-app
```

2. **Navigate to the project directory:**

```
cd tasker-socket-app

```

3. **Get dependencies:**

```
flutter pub get

```

4. **Run the application:**

```
flutter run

```

## ✨ Features

**Core Features:**

- Create, read, update, and delete items
- Real-time synchronization across devices
- Swipe-to-delete with dismissible cards
- Form validation and error handling

**UI/UX:**

- Modern green-themed design
- Google Fonts (Inter) typography
- Smooth animations and transitions
- Loading states and user feedback
- Active users counter

**Technical:**

- WebSocket real-time updates
- BLoC state management
- Clean Architecture
- Pull-to-refresh functionality

## 📂 Folder Structure

```
lib/
 ├── core/                 # Core concerns
 ├── data/                # Data sources and models
 ├── domain/              # Business logic and entities
 └── presentation/        # UI components and BLoC

```

## 🔧 Key Dependencies

```
dependencies:
  flutter_bloc: ^9.1.1          # State management
  google_fonts: ^6.2.1          # Typography
  flutter_slidable: ^4.0.0      # Swipe actions
  equatable: ^2.0.7             # Value equality
  dio: ^5.8.0+1                 # A powerful HTTP client for Dart.
  web_socket_channel: ^3.0.3    # Provides WebSocket support.
  dartz: ^0.10.1                # Functional programming tools for Dart.
  get_it: ^8.0.3                # Dependency injection library for Dart and Flutter.


```

---

**Built with using Flutter**
