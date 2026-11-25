# \# Flutter Task Manager with Back4App

# 

# A cloud-based task management web application developed using Flutter and Back4App (BaaS) for the Cloud Computing (SE ZG585) assignment at BITS Pilani WILP.

# 

# \## Features

# 

# \- User registration, login and logout.

# \- Task creation, viewing, updating and deletion (CRUD).

# \- Mark tasks as completed or pending.

# \- Dashboard with task statistics.

# \- Cloud database storage and session persistence.

# \- User-specific task access using ACL.

# 

# \## Technology Stack

# 

# \- \*\*Frontend:\*\* Flutter and Dart

# \- \*\*Backend:\*\* Back4App (Parse SDK)

# \- \*\*Database:\*\* Back4App Cloud Database

# \- \*\*Platform:\*\* Web

# 

# \## Architecture

# 

# Flutter UI → Authentication and Task Services → Parse SDK → Back4App Cloud Database

# 

# \## Setup and Execution

# 

# 1\. Clone the repository.

# 2\. Copy `lib/config/parse\_config.dart.example` to `lib/config/parse\_config.dart`.

# 3\. Configure your Back4App Application ID, Client Key, Task class and access permissions.

# 4\. Execute:

# 

# &#x20;  `flutter pub get`

# 

# &#x20;  `flutter run -d chrome --web-port=8080`

# 

# 5\. Access the application at http://localhost:8080.

# 

# \## Application Screenshots

# 

# \### Welcome Screen

# !\[Welcome Screen](screenshots/Welcome\_Screen.png)

# 

# \### Task Dashboard

# !\[Dashboard](screenshots/after\_login.png)

# 

# \### Task Creation and Completion

# !\[Task Creation](screenshots/tasks\_Add\_complete.png)

# 

# \### Task Update

# !\[Task Update](screenshots/Task\_updated.png)

# 

# \### Task Deletion

# !\[Task Deletion](screenshots/task\_deletion.png)

# 

# \### Back4App Integration

# !\[Back4App](screenshots/back4app.png)

# 

# \### Cloud Database

# !\[Database](screenshots/backend\_tasks\_ss.png)

# 

# \## Testing

# 

# Authentication, CRUD operations, user-specific task isolation, session persistence and logout were successfully tested.

