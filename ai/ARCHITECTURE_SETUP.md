# Clean Architecture Setup Guide

This document explains the Clean Architecture foundation that has been set up for migrating from SDK-based to API-based architecture.

## 📁 Structure Overview

The foundation follows Clean Architecture with three main layers:

```
lib/
├── core/                           # Core infrastructure
│   ├── network/                   # Network layer
│   │   ├── dio_client.dart        # HTTP client
│   │   ├── api_interceptor.dart   # Request/response interceptors
│   │   └── api_routes.dart        # API endpoint definitions (add your endpoints here)
│   ├── storage/                   # Storage layer
│   │   ├── shared_prefs_helper.dart
│   │   └── secure_storage_helper.dart
│   ├── di/                        # Dependency Injection
│   │   └── provider_setup.dart    # Core providers
│   └── error_handling/            # Error handling
│       ├── error_mapper.dart
│       └── error_handler.dart
│
├── domain/                        # Business Logic Layer
│   ├── entities/                  # Domain entities/DTOs
│   │   └── base_entity.dart
│   └── usecases/                  # Business use cases
│       └── base_usecase.dart
│
├── data/                          # Data Layer
│   ├── datasources/               # Data sources
│   │   ├── remote/                # Remote API data sources
│   │   └── local/                 # Local storage data sources
│   ├── repositories/              # Repository implementations
│   └── models/                    # Data models (API responses)
│
└── presentation/                  # UI Layer
    ├── views/                     # UI Screens
    ├── viewmodels/                # State management
    │   └── base_viewmodel.dart
    └── widgets/                   # Reusable components
```
 