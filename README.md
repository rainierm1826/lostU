# LOSTU – A Mobile-Based Lost and Found Management System for Batangas State University

## 📱 Project Description

**LOSTU** is a mobile-based application designed to streamline the process of reporting, managing, and recovering lost and found items within Batangas State University. Traditionally, the university relies on manual and informal methods such as word-of-mouth, drop boxes, or social media. LOSTU introduces a centralized, secure, and user-friendly platform that enables students and administrators to manage lost items efficiently.

## 🎯 Problem Statement

The current process for handling lost and found items in Batangas State University is disorganized and inefficient. It depends on manual reporting and social media, which makes tracking and recovering items unreliable. There is also no analytics system to inform the university about loss patterns, common locations, or recovery trends.

LOSTU solves this by introducing a structured mobile solution with Firebase integration that provides analytics, traceability, and enhanced communication between item owners and finders.

## ✅ Objectives

- Develop a Flutter-based mobile application for students and administrators.
- Allow users to report, browse, and claim lost items through a secure platform.
- Provide an admin panel for managing posts and viewing analytics.
- Generate insights from Firebase Analytics to support data-driven decisions.

## 🛠️ Development Model

- **Development Methodology**: RAD
- **Platform**: Mobile
- **Tech Stack**:
  - **Frontend**: Flutter (Dart)
  - **Backend/Database**: Firebase Firestore, Firebase Auth

## 👤 User Roles

### 1. User

- Log in using student portal credentials
- Report lost items with details and optional photo
- Search/filter items by category, location, and date
- Claim a lost item and track claim status

### 2. Admin

- Log in securely to the admin dashboard
- View and remove item listings
- View analytics (e.g., reports count, claim success rate, popular categories)

## 🔐 Functional Requirements

| Role  | Requirement                                                                     |
| ----- | ------------------------------------------------------------------------------- |
| User  | Login using student portal credentials                                          |
| User  | Post lost items with title, description, category, location, and optional photo |
| User  | Browse/search/filter items                                                      |
| User  | Claim items and check claim/report status                                       |
| Admin | Login securely                                                                  |
| Admin | View/remove lost item posts                                                     |
| Admin | Access analytics dashboard                                                      |

## 📲 Features Summary

- 🧾 Lost Item Posting
- 🔍 Search
- 📩 Claim Requests
- 📊 Analytics for Admins
- 🖼️ Image Upload Support
- 🔒 Secure Auth (Firebase)

## 🧪 User Acceptance Testing (UAT)

UAT was conducted to validate that the LOSTU application meets all functional requirements. Below are the details:

### UAT Environment

| Item             | Description              |
| ---------------- | ------------------------ |
| Device           | Android Phone / Emulator |
| OS Version       | Android 12+              |
| App Version      | 1.0.0                    |
| Development Tool | Flutter                  |
| Framework        | Flutter SDK 3.x          |
| Testing Tool     | Manual User Testing      |

### Test Cases

| Test Case ID | Test Scenario             | Description                         | Expected Result                   | Actual Result     | Status    |
| ------------ | ------------------------- | ----------------------------------- | --------------------------------- | ----------------- | --------- |
| UAT-01       | Login Functionality       | Login using student credentials     | User logs in and sees home screen | Works as expected | ✅ Passed |
| UAT-02       | Post Lost Item            | Submit lost item details            | Item appears in list              | Works as expected | ✅ Passed |
| UAT-03       | Search Lost Items         | Use filters to search items         | Relevant items displayed          | Works as expected | ✅ Passed |
| UAT-04       | Claim Lost Item           | Submit claim for an item            | Claim marked as pending           | Works as expected | ✅ Passed |
| UAT-05       | View Claim/Report Status  | Check claim/report progress         | Status displayed correctly        | Works as expected | ✅ Passed |
| UAT-06       | Admin Login               | Admin login to dashboard            | Admin redirected to panel         | Works as expected | ✅ Passed |
| UAT-07       | Admin - Manage Lost Posts | Admin views/removes items           | Items updated/removed             | Works as expected | ✅ Passed |
| UAT-08       | Admin - View Analytics    | See analytics on reports and claims | Analytics data shown              | Works as expected | ✅ Passed |
| UAT-09       | View Item Details         | View full details of a lost item    | Description and photo displayed   |

## 📃 License

This project is for academic purposes at Batangas State University. Redistribution or commercial use requires permission from the project authors.

---
