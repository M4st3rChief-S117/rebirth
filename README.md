# Base Flutter Template

A production-ready Flutter starter template with built-in authentication, API integration, routing, and state management.

## Features

- **Authentication**: JWT-based authentication with secure token storage
- **API Integration**: HTTP client for backend communication
- **Routing**: GoRouter for declarative navigation
- **State Management**: Provider for reactive state management
- **Secure Storage**: Flutter Secure Storage for sensitive data
- **Animated UI**: Custom animated bubble menu component
- **Material Design 3**: Modern UI with Material 3 support
- **Multi-platform**: Support for iOS, Android, Web, and more

## Project Structure

```
lib/
├── main.dart                  # App entry point with routing and state setup
├── router.dart                # GoRouter configuration
├── api_service.dart           # HTTP client and API calls
├── token_storage_service.dart # Secure token storage
├── login_page.dart            # Authentication page
├── animated_bubble_menu.dart  # Custom animated menu widget
├── app_colors.dart            # App color scheme
```

## Getting Started

### Prerequisites

- Flutter 3.12.0 or higher
- Dart 3.12.0 or higher

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd base_flutter_template
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Key Components

### Authentication

The template includes JWT-based authentication:

- **TokenStorageService**: Securely stores and retrieves JWT tokens using Flutter Secure Storage
- **ApiService**: Handles authenticated API requests with automatic token injection
- **LoginPage**: User authentication interface

### API Service

`ApiService` provides a centralized HTTP client with:
- Automatic token attachment to requests
- Error handling
- Request/response logging

```dart
final apiService = Provider.of<ApiService>(context, listen: false);
final response = await apiService.getRequest('/endpoint');
```

### Routing

Navigation is handled by GoRouter with automatic token-based route protection. Define your routes in `router.dart`.

### State Management

Uses Provider for reactive state management:

```dart
final apiService = Provider.of<ApiService>(context);
// Listen to changes automatically
```

### Animated Bubble Menu

A custom animated floating menu component with smooth animations and customizable items.

## Configuration

### Dependencies

- `cupertino_icons`: iOS-style icons
- `jwt_decode`: JWT token decoding
- `http`: HTTP client
- `go_router`: Navigation
- `provider`: State management
- `flutter_secure_storage`: Secure credential storage
- `web`: Web platform support

