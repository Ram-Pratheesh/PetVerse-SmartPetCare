# PetVerse 🐾

**PetVerse** is a cross-platform mobile application built using **Flutter** and integrated with **Firebase**, **MongoDB**, and an embedded **TFLite** machine learning model. It is designed to offer an all-in-one intelligent ecosystem for modern pet care, including real-time lost and found alerts, breed-specific health tips, emergency vet assistance, adoption support, and a community chat system.

---

## ✨ Features

### 📍 1. Lost & Found Pet Reporting
- Real-time alerts for missing or found pets.
- Geolocation-based filtering (10 km radius).
- Image upload using **Cloudinary**.
- Metadata stored in **Firebase Firestore**.

### 🧐 2. Breed-Specific Care Tips (ML-Integrated)
- Embedded **TFLite** model for offline prediction.
- Takes a breed as input and outputs care suggestions in:
  - Health
  - Grooming
  - Feeding
  - Daily Reminders
- Tips rendered as stylish UI cards in real-time.

### 🚪 3. Login & Signup (Auth System)
- Role-based authentication (User / NGO / Admin).
- Authentication handled using **MongoDB + Express.js** backend.
- Secure login and data protection with hashed passwords.

### 🚑 4. Emergency Vet Assistance
- One-tap **SOS button** for emergency vet contact.
- Uses **Google Maps API** to locate nearby clinics.
- Shows clinics within user-defined radius with contact info.

### 🫰 5. Pet Essentials Delivery
- Module for on-demand product requests (future integration with store APIs).
- Simple cart UI integrated with user profile.

### 🛏️ 6. Pet Adoption Listings
- NGO-authenticated uploads for available pets.
- Users can filter by breed, location, age.
- Inquiry system for adopters.

### 📘 7. Vaccination Tracker
- Track upcoming and completed vaccination dates.
- Store vet notes and health logs in Firestore.
- Local notifications for upcoming schedules.

### 💬 8. Chat System (Community)
- Real-time messaging via **Firebase Firestore**.
- One-on-one or group chat between users.
- Support for multimedia messaging and typing indicators.

### 🌍 9. GPS-Based Service Finder
- Google Maps integration to locate:
  - Vets
  - Groomers
  - Boarding facilities
  - Pet stores

---

## 📈 ML Model Info
- Trained using Keras on synthetic dataset (20 breeds).
- Output: Multilabel classification (Health, Grooming, Feeding, Reminder).
- Accuracy:
  - Health: 87.2%
  - Grooming: 78.8%
  - Feeding: 75.0%
  - Reminder: 83.0%
- Exported to `.tflite` and quantized for mobile integration

---

## 🚀 Tech Stack
- **Frontend:** Flutter
- **ML:** TensorFlow Lite
- **Backend Auth:** Node.js + Express + MongoDB
- **Database:** Firebase Firestore
- **Media Storage:** Cloudinary
- **APIs:** Google Maps, Cloud Functions

---

## 🚜 Future Enhancements
- Voice Assistant integration
- AI-driven pet health forecasting
- NGO dashboard for adoption workflows
- Integration with vet databases and e-commerce APIs
- Wearable device sync for live tracking

---

## 📅 License
This project is licensed under the MIT License. Feel free to fork and customize.

---

## 🙏 Acknowledgments
Special thanks to our faculty mentor and contributors who supported development and testing throughout this project.

---

> “Reimagining pet care, one tap at a time.” — Team PetVerse

