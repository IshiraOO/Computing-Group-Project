# First Aid Health Care App

The First Aid Health Care App is a cross-platform mobile application built using Flutter and Firebase, developed as a part of a computing group project. This application serves as a digital guide for delivering first aid care, educating users on how to respond to various health emergencies effectively. It provides categorized guidance, symptom analysis, emergency contacts, and access to nearby healthcare services, making it a comprehensive tool for health and safety.

# Features

This application includes the following major features:

First Aid Guide: Provides well-structured instructions on how to handle different types of medical emergencies. Each instruction is detailed and tailored to specific conditions.
Emergency Services: Offers quick access to local emergency contacts and hospital locators. It supports geolocation-based service suggestions using location APIs.
Symptom Analysis: Allows users to input their symptoms and receive preliminary advice or treatment suggestions based on common patterns, utilizing a custom-built analysis service.
Health Journal: A feature for users to maintain daily health logs and reflect on medical symptoms over time. The data is securely stored using Firebase Firestore.
Community Support: Users can create, view, and respond to posts in a community-driven forum, promoting health-related discussions and peer support.
Training Modules: Provides educational content and training resources related to health and first aid, allowing users to build knowledge at their own pace.
User Authentication and Profiles: Supports secure user registration, login, and profile editing using Firebase Authentication. Each profile contains basic information and preferences.
Clean Navigation UI: The app includes a consistent UI with custom widgets for app bars, buttons, cards, and bottom navigation.

# Technologies Used

Flutter: For cross-platform development (Android, iOS, macOS)
Dart: The primary programming language used with Flutter
Firebase Firestore: For real-time data storage and retrieval
Firebase Authentication: For managing user login and registration
Google Maps / Location Services: For locating nearby medical facilities
Local Storage: For caching and local data handling using services
# Project Structure

The app follows a modular architecture for scalability and maintainability.
## Key Directories:
The **First Aid Health Care App** follows a well-structured and modular project architecture to ensure maintainability and scalability. The `models/` directory contains all data models such as `illness.dart`, `user_profile.dart`, and `community_post.dart`, which represent the structured data used throughout the application. The `screens/` directory includes all the major user interface screens, such as `home_screen.dart` for the main dashboard, `first_aid_screen.dart` and `first_aid_detail_screen.dart` for accessing detailed first aid instructions, and `login_screen.dart` along with `register_screen.dart` for managing user authentication. Additional screens include `symptom_analysis_screen.dart` for analyzing user symptoms, `training_modules_screen.dart` and `training_module_detail_screen.dart` for learning resources, `hospital_locator_screen.dart` for locating nearby hospitals using map services, `community_support_screen.dart` and `create_community_post_screen.dart` for user discussions and peer interaction, and `health_journal_screen.dart` for maintaining a daily health log.

The `services/` directory serves as the core business logic layer, containing files such as `auth_service.dart` for managing authentication processes, `firebase_service.dart` for interacting with Firebase Firestore, `symptom_analysis_service.dart` for processing symptom data, `emergency_service.dart` for managing emergency calls, and `training_module_service.dart` for fetching and managing training resources. To ensure consistency and reusability across the user interface, the `widgets/` directory includes common UI components such as `custom_app_bar.dart`, `custom_bottom_nav_bar.dart`, `custom_card.dart`, `custom_button.dart`, `screen_header.dart`, and `custom_search_bar.dart`. Shared configurations and styling constants are managed in the `common/` directory, including the centralized theming file `app_theme.dart`. The project is bootstrapped through `main.dart`, which serves as the application's entry point and sets up both the navigation logic and authentication wrappers. Additionally, `firebase_options.dart` is used for Firebase configuration, enabling seamless integration with the backend.

This app follows the separation of concerns principle by isolating data models, service layers, UI screens, and reusable widgets. It allows for easier testing, extension, and team collaboration.

Model-View-Service (MVS) approach separates logic into distinct roles.
Theming and Styling are centralized via app_theme.dart to maintain UI consistency.
Routing and Navigation are managed centrally in main_navigation_screen.dart.
Firebase Integration

# The Firebase backend is used for:

User Authentication: Registering and logging in users securely.
Cloud Firestore: Storing structured data such as posts, journal entries, training content, and user profiles.
Rules and Indexing: Managed via firestore.rules and firestore.indexes.json.
# Notes

The project is configured for Android, iOS, and macOS platforms.
Ensure you have added your platform-specific Firebase configuration files:
google-services.json for Android
GoogleService-Info.plist for iOS
All user data is stored securely, and proper validation is enforced in forms and data models.
# Conclusion

The First Aid Health Care app provides an accessible way for individuals to prepare for and respond to medical emergencies. It merges educational content, personal health tracking, community interaction, and practical tools like symptom analysis and location services. Built with scalability and modularity in mind, this application can be extended with future features such as voice input, AI-driven recommendations, or offline access.
