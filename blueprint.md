# IT Service Management App

## Overview

This Flutter application is a comprehensive tool for IT service professionals to manage their jobs, contacts, and schedule. It leverages Firebase for backend services, including authentication, Firestore database, and storage. The app is designed with a clean, modern, and user-friendly interface, following Material Design 3 principles.

## Features

- **Authentication:** Secure user login with Firebase Authentication.
- **Job Management:** Create, view, update, and delete service jobs. Each job includes a title, description, status, due date, and address.
- **Contact Management:** Maintain a list of clients with their name, email, phone number, and address.
- **Calendar View:** An interactive calendar to visualize job deadlines and important dates.
- **Dashboard:** A home screen providing a quick overview of active jobs, total contacts, and upcoming deadlines.
- **Photo Gallery:** Attach and view multiple photos for each job.
- **Geolocation:** Display job locations on a Google Map.
- **Theming:** Supports both light and dark modes with a customizable theme.
- **Responsive Design:** The app is designed to work on various screen sizes.

## Design

- **Typography:** The app uses the `google_fonts` package to implement a clean and readable typography scheme with `Oswald` for display text and `Roboto` for body text.
- **Color Scheme:** A color scheme generated from a seed color (`Colors.blue`) using `ColorScheme.fromSeed` for a consistent and modern look.
- **Component Styling:** Custom themes for AppBar, ElevatedButton, and other Material components to ensure a cohesive design.
- **Navigation:** A `BottomNavigationBar` for easy navigation between the main screens (Home, Jobs, Calendar, Contacts), implemented with `go_router` for a robust and declarative routing solution.
- **Layout:** The app uses a combination of `ListView`, `CustomScrollView`, `Card`, and other layout widgets to create a visually appealing and organized interface.

## Current Plan

- **Task:** Improve the user interface and user experience of the application.
- **Steps:**
    - [x] Update the `add_job_screen.dart` with a more visually appealing and user-friendly design.
    - [x] Update the `job_detail_screen.dart` to improve its UI.
    - [x] Update the `contact_detail_screen.dart` to improve its UI.
    - [x] Add the `url_launcher` package to the `pubspec.yaml`.
    - [x] Update the `main.dart` with a better UI.
    - [x] Create the `home_screen.dart` file to provide a better UI.
    - [x] Update the `main.dart` file to use this new screen as the initial route when the user is logged in.
    - [x] Update the `home_screen.dart` to provide a more visually appealing and informative dashboard for the user.
    - [x] Create the `blueprint.md` file to provide a better overview of the application's features and design.
    - [x] Update the `auth_screen.dart` with a more modern and user-friendly design.
    - [x] Update the `add_contact_screen.dart` to improve its UI.
    - [x] Update the `contacts_screen.dart` to improve its UI.
    - [x] Add the `table_calendar` package to `pubspec.yaml`.
    - [x] Update the `calendar_screen.dart` with a more modern and user-friendly design.
    - [x] Update the `blueprint.md` file to reflect the changes made.
