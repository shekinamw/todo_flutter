# To-Do Mobile App (Flutter/Dart Version) [CLASS PROJECT]

This project is the **Flutter/Dart implementation** of the To-Do mobile app designed in earlier labs.  
It recreates the core functionality of the previous versions while introducing Flutter’s UI components and state management.

---

##  Lab Overview

The goal of this lab is to build a **basic To-Do application** using **Flutter and Dart**, applying concepts learned in past labs while exploring Flutter's widget-based architecture.

---

## Objectives

Your Flutter To-Do app must include:

- **Home Screen**
- **New Task Screen**
- **App Bar** (on both screens)
- **Floating Action Button** (Home Screen)
- **Task List Display** (based on current session state)
- **Customized UI styling**

---

## Requirements Breakdown

### Home Screen
- Display all tasks created within the same session (stored in state).
- If no tasks exist, show **“No tasks here.”**
- Include a **Floating Action Button (FAB)** to navigate to the New Task Screen.

---

### New Task Screen
Must include:
- **Title**, **Deadline**, and **Description** input fields.
- A **Submit/Save** button.
- A **Back Arrow** in the App Bar to return to the Home Screen.

Behavior:
- On clicking **Submit/Save**, the app:
    - Validates inputs.
    - Stores the new task in state.
    - Navigates back to the Home Screen.
- If required fields are missing:
    - Show an **error message**.
    - Stay on the New Task Screen until corrected.

---

###  Styling & Customization
Your app must include **custom UI elements** beyond Flutter’s defaults.  
You can add unique styling such as:

- Custom **theme** (color palette)
- **New fonts**
- **Background images**
- Any other creative UI enhancements



---

