# Kaburlu

Kaburlu is a messaging application designed to offer seamless and efficient communication. Leveraging Firebase Firestore for real-time message delivery, Kaburlu integrates several advanced features to enhance user experience. Users can sign in effortlessly using their Google accounts, add contacts via email addresses, and create detailed profiles. The app includes functionalities such as message read status, message deletion, and editing, ensuring users have full control over their conversations. Additionally, Kaburlu employs on-device machine learning to provide smart reply suggestions, making communication faster and more intuitive.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Set up android studio for flutter environment](https://www.youtube.com/watch?v=hfz_AraTk_k&feature=youtu.be&ab_channel=GeeksforGeeks)
- [Integrate Firebase in the app](https://www.youtube.com/watch?v=sz4slPFwEvs)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Kaburlu (Cross Platform App)

## Setting up the project in your local environment💻

1. [Clone this repository](https://github.com/lazypanda2004/Kaburlu) this repository.
2. After Cloning, open the project in Android studio
3. Create a new project on [Firebase Console](https://console.firebase.google.com/)
4. Activate Email SignIn in Firebase auth, and activate Firebase Firestore and Firebase Storage in **test mode**, and change the rules accordingly.
5. Integrate Firebase to use your own database
6. Run `flutter pub get` to get the dependencies.
7. Finally, run the app:

```
flutter run
```

## Features

- **Real-Time Messaging:** Send and receive messages instantly with Firebase Firestore.
- **Google Sign-In:** Sign in using Google accounts without the need for mobile numbers.
- **Adding Users:** Add other users to your contact list using their email addresses.
- **User Profiles:** Create profiles with Display Photo, Status, Email, Password, last-seen status, and account creation date.
- **Message Read Status:** See if your messages have been read by the recipient.
- **Message Delete:** Delete sent messages either for yourself or both users.
- **Message Edit:** Edit sent messages.
- **Smart Reply Generation:** Generate intelligent replies based on received messages using on-device ML.

## Tech Stack

- **Flutter:** For building the user interface.
- **Firebase:** For real-time messaging, authentication, and data storage.
- **Firestore:** For storing chat messages and user data.
- **MLKit (TensorFlow Lite):** For generating smart replies using on-device machine learning.

