# CivicLink 🏙️

### Local Issue Reporting & Accountability System

CivicLink is a Flutter-based civic issue reporting and accountability platform that connects **citizens, administrators, and government departments** to make local issue reporting and resolution more transparent and organized.

Citizens can report issues such as road damage, water leakage, electricity problems, and sanitation issues with **images and location details**. Administrators verify and assign issues to the appropriate department, while departments can track the issue, update its progress, and upload **resolution proof** after completing the work.

---

## 🚀 Features

### 👤 Citizen

* Register and login
* Report local civic issues
* Add issue title and description
* Select issue category
* Capture/upload issue images
* Automatically obtain current location
* View submitted issues
* Track issue status
* View complete issue details
* View status timeline
* View department remarks
* View resolution proof images

### 🛠️ Admin

* Secure admin login
* View submitted issues
* Review complete issue information
* View citizen details
* Verify or reject reported issues
* Assign verified issues to departments
* Monitor issue workflow

### 🏢 Department

* Department-specific dashboard
* View assigned issues
* View complete issue and citizen information
* Mark assigned issues as **In Progress**
* Add resolution remarks
* Upload resolution proof
* Mark issues as **Resolved**

---

## 🔄 Issue Workflow

```text
Citizen Reports Issue
        │
        ▼
    Submitted
        │
        ▼
 Admin Verifies Issue
        │
        ▼
     Verified
        │
        ▼
Admin Assigns Department
        │
        ▼
     Assigned
        │
        ▼
Department Starts Work
        │
        ▼
   In Progress
        │
        ▼
Department Adds Remark
        │
        ▼
Upload Resolution Proof
        │
        ▼
     Resolved
```

This workflow ensures that an issue cannot be assigned to a department before it has been verified by an administrator.

---

## 🏗️ System Architecture

```text
                    ┌─────────────────┐
                    │     Citizen     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Flutter App   │
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
        ┌───────────────┐         ┌───────────────┐
        │ Firebase Auth │         │   Firestore   │
        └───────────────┘         └───────┬───────┘
                                          │
                                          ▼
                                  ┌───────────────┐
                                  │     Admin     │
                                  └───────┬───────┘
                                          │
                                          ▼
                                  Assign Department
                                          │
                                          ▼
                                  ┌───────────────┐
                                  │  Department   │
                                  └───────┬───────┘
                                          │
                                          ▼
                                  Update / Resolve
                                          │
                                          ▼
                                  ┌───────────────┐
                                  │   Cloudinary  │
                                  │  Image Storage│
                                  └───────────────┘
```

---

## 🛠️ Tech Stack

| Technology                          | Purpose                            |
| ----------------------------------- | ---------------------------------- |
| **Flutter**                         | Cross-platform mobile application  |
| **Dart**                            | Application development            |
| **Firebase Authentication**         | User authentication                |
| **Cloud Firestore**                 | Database and real-time data        |
| **Cloudinary**                      | Image storage and hosting          |
| **Google Maps / Location Services** | Issue location tracking            |
| **Image Picker**                    | Camera and gallery image selection |
| **VS Code**                         | Development environment            |
| **Android Emulator**                | Application testing                |

---

## 📱 Application Modules

### Authentication Module

Handles:

* User registration
* User login
* Role-based navigation
* Logout
* User information retrieval

Supported roles:

```text
Citizen
Admin
Department
```

---

### Citizen Module

The citizen can create a new issue by providing:

```text
Title
Description
Issue Type
Image
Location
```

The issue is then stored in Firestore and the uploaded image is hosted on Cloudinary.

Citizens can also track the complete lifecycle of their reported issues.

---

### Admin Module

The administrator acts as the verification and assignment layer.

Admin can:

```text
View Submitted Issues
        ↓
Review Issue
        ↓
Verify / Reject
        ↓
Assign Department
```

Available departments include:

* Road Department
* Water Department
* Electricity Department
* Sanitation Department

---

### Department Module

Departments only see issues assigned to them.

The department workflow is:

```text
Assigned
   ↓
In Progress
   ↓
Resolution Remark
   ↓
Resolution Image
   ↓
Resolved
```

This provides citizens with evidence that the reported issue has been addressed.

---

## ☁️ Image Management

CivicLink uses **Cloudinary** for image hosting instead of Firebase Storage.

### Image Upload Flow

```text
Camera / Gallery
       ↓
   Image Picker
       ↓
   Local Preview
       ↓
    Cloudinary
       ↓
   Secure Image URL
       ↓
     Firestore
```

Two types of images are stored:

### Citizen Image

The original image submitted while reporting the issue.

```text
imageUrl
```

### Resolution Image

The image uploaded by the department after resolving the issue.

```text
resolvedImageUrl
```

---

## 📍 Location Tracking

CivicLink uses device location services to capture the location where an issue was reported.

The issue stores location information such as:

```text
latitude
longitude
locationUrl
```

Citizens, administrators, and departments can open the reported location externally.

---

## 🔥 Firebase

Firebase is used for authentication and application data management.

### Firebase Authentication

Used for:

* Registration
* Login
* User identification
* Session management

### Cloud Firestore

Used to store:

* User information
* Issue information
* Issue status
* Department assignment
* Status history
* Resolution remarks
* Image URLs

---

## 🗄️ Firestore Data Structure

A typical issue document contains fields such as:

```text
issues
│
├── title
├── description
├── issueType
├── status
├── submittedBy
├── assignedTo
├── imageUrl
├── resolvedImageUrl
├── latitude
├── longitude
├── locationUrl
├── departmentRemark
├── statusHistory
├── createdAt
├── updatedAt
└── resolvedAt
```

### Status History

The application maintains a timeline of status changes:

```json
[
  {
    "status": "Submitted",
    "timestamp": "..."
  },
  {
    "status": "Verified",
    "timestamp": "..."
  },
  {
    "status": "Assigned",
    "timestamp": "..."
  },
  {
    "status": "In Progress",
    "timestamp": "..."
  },
  {
    "status": "Resolved",
    "timestamp": "..."
  }
]
```

---

## 📂 Project Structure

```text
lib/
│
├── main.dart
│
├── core/
│   └── services/
│       ├── auth_service.dart
│       ├── issue_service.dart
│       ├── location_service.dart
│       └── cloudinary_service.dart
│
├── models/
│   └── issue_model.dart
│
├── screens/
│   │
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   │
│   ├── citizen/
│   │   ├── citizen_home.dart
│   │   ├── report_issue_screen.dart
│   │   ├── my_issues_screen.dart
│   │   └── citizen_issue_details_screen.dart
│   │
│   ├── admins/
│   │   ├── admin_dashboard.dart
│   │   └── issue_details_screen.dart
│   │
│   └── department/
│       ├── department_dashboard.dart
│       └── department_issue_details_screen.dart
│
└── utils/
    └── constants.dart
```

---

## ⚙️ Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/RIOT7077/CivicLink.git
```

```bash
cd CivicLink
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Create a Firebase project and configure Firebase for the Flutter application.

Enable:

* Firebase Authentication
* Cloud Firestore

Add the required Firebase configuration files for Android.

### 4. Configure Cloudinary

Create a Cloudinary account and configure an unsigned upload preset.

Update:

```text
lib/core/services/cloudinary_service.dart
```

with your Cloudinary configuration:

```dart
static const String cloudName = 'YOUR_CLOUD_NAME';
static const String uploadPreset = 'YOUR_UPLOAD_PRESET';
```

> For a production application, sensitive configuration and upload permissions should be handled securely rather than exposing unrestricted client-side credentials.

### 5. Run the Application

Start an Android emulator or connect a physical device and run:

```bash
flutter run
```

---

## 🔐 User Roles

| Role          | Responsibilities                         |
| ------------- | ---------------------------------------- |
| 👤 Citizen    | Report and track issues                  |
| 🛠️ Admin     | Verify and assign issues                 |
| 🏢 Department | Work on assigned issues and resolve them |

---

## 🎯 Project Objectives

CivicLink was developed with the following objectives:

* Simplify civic issue reporting
* Provide location-based issue information
* Create a structured verification process
* Improve communication between citizens and departments
* Provide transparent issue status tracking
* Maintain resolution evidence
* Organize issues according to responsible departments

---

## 🔮 Future Improvements

Possible future enhancements include:

* 🤖 AI-based issue classification
* 📊 Advanced analytics dashboard
* 🔔 Push notifications
* 🗺️ Interactive issue map
* 👍 Community upvoting
* 🚨 Automatic issue priority detection
* 📈 Department performance analytics
* 🔐 Improved role-based security
* 🌐 Web-based admin dashboard
* 📱 Improved accessibility and multilingual support

---

## 🧪 Testing

The application can be tested using:

* Android Emulator
* Physical Android devices
* Different user roles
* Different issue categories
* Different issue statuses
* Camera and gallery uploads
* Location services
* Firestore real-time updates

---

## 🤝 Contribution

Contributions, suggestions, and improvements are welcome.

To contribute:

```bash
git fork
git clone <your-fork>
git checkout -b feature/your-feature
```

Make your changes, commit them, and create a pull request.

---

## 📄 License

This project is developed for educational and demonstration purposes.

---

## 👨‍💻 Developer

**Karan Kale**

Computer Science Engineering Student

GitHub: **[@RIOT7077](https://github.com/RIOT7077)**

---

## ⭐ Support

If you found this project useful or interesting, consider giving the repository a ⭐ on GitHub.
