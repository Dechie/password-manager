# Secure Password Manager

Secure Password Manager is a Flutter-based application that provides a secure way to store and manage your passwords. It utilizes the Hive database and the Flutter Secure Storage plugin to ensure the safety of your sensitive information.

## Features

- Secure storage of passwords using AES encryption
- Backup and restore functionality to protect your data
- Password strength validation to encourage the use of strong passwords

## Getting Started

### Prerequisites

- Flutter SDK installed on your development machine
- Android Studio or Xcode (depending on your target platform)

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/your-username/secure-password-manager.git
   ```

2. Navigate to the project directory:

   ```
   cd secure-password-manager
   ```

3. Install the dependencies:

   ```
   flutter pub get
   ```

4. Run the app:

   ```
   flutter run
   ```

### Usage

1. When the app is launched for the first time, you will be prompted to create a PIN code for authentication.
2. After setting up the PIN, you can start adding, editing, and deleting your passwords.
3. The app will automatically encrypt your password data using the generated encryption key, which is securely stored in the device's secure storage.

## Security Considerations

- The app uses the `FlutterSecureStorage` plugin to securely store the encryption key used for Hive database encryption.
- All password data is encrypted using AES encryption before being stored in the Hive database.
- The app does not store or transmit any sensitive information outside of the device.
- The app includes password strength validation to encourage the use of strong passwords.

## Future Improvements

- Implement a secure backup and restore mechanism for the user's password data.
- Add support for password sharing and collaboration features.
- Integrate with popular password managers for seamless data migration.
- Provide an option to generate strong, random passwords.

## Contributing

If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

## License

This project is licensed under the [GPL License](LICENSE).
