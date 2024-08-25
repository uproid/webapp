# WebApp Package

The WebApp package allows you to easily develop a powerful web application using Dart. This tool comes with several advantages, including support for MongoDB and WebSocket.

## Purpose

The WebApp package is designed for:

- Rapid development of APIs
- Structuring web projects efficiently
- Utilizing MongoDB as the database
- Creating widgets for frontend display
- Developing WebSocket requests
- Integration with Nginx

## Getting Started

To get started with the WebApp package, follow these steps to run the provided example:

1. **Install Dependencies**:
   ```sh
   dart pub get
   ```

2. **Run the Example**:
   ```sh
   dart run ./example/example.dart
   ```

3. The output will be available at:
   ```
   http//localhost:8085
   ```

For a better understanding of the features, please explore the `example` directory.

## Features

- **Rapid API Development**: Quickly create and manage APIs for your web application.
- **MongoDB Support**: Easily integrate MongoDB for database management.
- **Widget Creation**: Develop widgets for rendering content on the frontend.
- **WebSocket Support**: Build interactive, real-time features with WebSocket.
- **Nginx Compatibility**: Seamlessly integrate with Nginx for robust server management.
- **SMTP Sender Email**: A utility class for sending emails using SMTP.
Feel free to explore and modify the example to suit your needs, and leverage the full potential of the WebApp package in your projects.

### Email SMTP example:
   ```
   import 'package:mailer/smtp_server.dart';
   
   bool success = await MailSender.sendEmail(
     from: 'sender@example.com',
     fromName: 'Sender Name',
     host: 'smtp.example.com',
     port: 587,
     to: ['recipient@example.com'],
     subject: 'Test Email',
     html: '<h1>Hello, World!</h1>',
     text: 'Hello, World!',
     username: 'smtp-username',
     password: 'smtp-password',
     ssl: true,
     allowInsecure: false,
   );
   ```