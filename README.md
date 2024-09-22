# WebApp Package

[![pub package](https://img.shields.io/pub/v/webapp.svg)](https://pub.dev/packages/webapp)
[![Dev](https://img.shields.io/pub/v/webapp.svg?label=dev&include_prereleases)](https://pub.dev/packages/webapp)
[![Donate](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-pink.svg)](https://buymeacoffee.com/fardziao)
[![issues-closed](https://img.shields.io/github/issues-closed/uproid/webapp?color=green)](https://github.com/uproid/webapp/issues?q=is%3Aissue+is%3Aclosed) 
[![issues-open](https://img.shields.io/github/issues-raw/uproid/webapp)](https://github.com/uproid/webapp/issues) 
[![Contributions](https://img.shields.io/github/contributors/uproid/webapp)](https://github.com/uproid/webapp/blob/master/CONTRIBUTING.md)

# WebApp Package Overview

WebApp Package is a robust Dart package designed to streamline the development of powerful web applications. Whether you're building APIs, managing databases, creating dynamic frontend widgets, or implementing real-time features, the WebApp package offers a comprehensive suite of tools to accelerate your development process. With built-in support for MongoDB, WebSockets, and seamless integration with Nginx, this package is ideal for developers seeking efficiency and scalability in their web projects.

#### [View Examples](https://github.com/uproid/webapp/tree/master/example)  |  [Live Demo](https://webapp.uproid.com) | [Documentations](https://github.com/uproid/webapp/tree/master/doc)

## Purpose

The WebApp package is crafted to facilitate:

- **Rapid API Development:** Quickly create and manage APIs, reducing development time.
- **Efficient Project Structuring:** Organize web projects for better maintainability and scalability.
- **MongoDB Integration:** Utilize MongoDB for efficient data storage and retrieval.
- **Frontend Widget Creation:** Develop reusable widgets for dynamic frontend interfaces.
- **WebSocket Implementation:** Build interactive, real-time features with ease.
- **Nginx Integration:** Deploy and manage your web application seamlessly with Nginx.
- **Comprehensive Tooling:** Simplify web development with built-in utilities for handling common data structures and operations.

1. [Overview](#webapp-package-overview)
2. [Installing](https://github.com/uproid/webapp/tree/master/doc/1.Installing.md)
3. [Example: Start Server](https://github.com/uproid/webapp/tree/master/doc/2.Example-start-server.md)
4. [Routing](https://github.com/uproid/webapp/tree/master/doc/3.Routing.md)
5. [Controllers](https://github.com/uproid/webapp/tree/master/doc/4.Controllers.md)
6. [Localization](https://github.com/uproid/webapp/tree/master/doc/5.Localization.md)
7. [Form Validators](https://github.com/uproid/webapp/tree/master/doc/6.FormValidators.md)
8. [Jinja Template Engine](https://github.com/uproid/webapp/tree/master/doc/7.jinja-template-engin.md)
9. [WebSocket](https://github.com/uproid/webapp/tree/master/doc/8.WebSocket.md)
10. [Cron Job](https://github.com/uproid/webapp/tree/master/doc/9.CronJob.md)
11. [Database](https://github.com/uproid/webapp/tree/master/doc/10.Database.md)
12. [Database Queries](https://github.com/uproid/webapp/tree/master/doc/11.DQ-Database-Queries.md)
13. [MongoDB Connection](https://github.com/uproid/webapp/tree/master/doc/12.Mongo-db-connection.md)
14. [Open API Documentation](https://github.com/uproid/webapp/tree/master/doc/13.open-api-documentation.md)

## Features

### 1. Rapid API Development
The WebApp package provides a streamlined framework for setting up and managing APIs. Define endpoints, handle requests, and manage responses effortlessly, enabling you to focus on building the core functionality of your application.

### 2. MongoDB Support
Integrate MongoDB seamlessly into your web application. The package offers tools to connect to MongoDB instances, perform CRUD operations, and manage data efficiently, ensuring robust backend support for your projects.

### 3. OpenAPI v3.0 Documentation Generation
Automatically generate OpenAPI v3.0 documentation for your APIs. This feature facilitates the use of UI tools like Swagger, providing an interactive interface for testing and exploring your APIs, enhancing developer and client experience.

### 4. Database Models and MongoDB Query Support
Create database models that map directly to your MongoDB collections. The package simplifies defining data schemas and building complex queries, enabling efficient data operations such as filtering, sorting, and aggregating within your Dart code.

### 5. Frontend Widget Creation
Develop and manage reusable frontend widgets to render dynamic content. The package supports the creation of interactive UI components, enhancing the user experience and ensuring consistency across your web application.

### 6. WebSocket Support
Implement real-time communication features using WebSockets. Whether you're building chat applications, live data feeds, or interactive dashboards, the WebApp package makes adding WebSocket functionality straightforward and efficient.

### 7. Nginx Compatibility
Deploy your Dart web application with ease using Nginx. The package is designed to work seamlessly with Nginx, providing robust and scalable server management suitable for production environments.

### 8. SMTP Email Sending
Send emails directly from your web application using the Simple Mail Transfer Protocol (SMTP). This feature is essential for functionalities like user registration, password recovery, and sending notifications.

### 9. Comprehensive Data Handling Tools
Simplify web development with built-in tools for managing common data structures such as Strings, Maps, and Lists. These utilities include string encoding and manipulation, as well as efficient handling of Maps and Lists, reducing the need for additional packages.

### 10. Advanced Routing with Authentication and Permissions
Handle client-side request routing effectively with built-in support for managing authentication and permissions. Define secure routes and control access to various parts of your application effortlessly.

### 11. Easy Socket Request Development
Develop and manage Socket requests with ease. The WebApp package provides intuitive APIs to handle Socket connections, enabling real-time data exchange and interactive features in your web application.

### 12. MVC Architecture for Scalability
Scale large projects effortlessly using the Model-View-Controller (MVC) architecture. Extend the provided classes such as `WaController`, `DBModel`, and `DBCollection` to structure your application logically and maintainably.

### 13. Form Validators
Utilize built-in FormValidators to manage and validate client-side data on the server. This feature ensures data integrity and security by validating API requests and user inputs effectively.

### 14. CronJob Development
Implement scheduled tasks quickly using the `WaCron` class. Automate routine operations, such as data backups or periodic data processing, with minimal configuration.

### 15. Flexible Output Rendering
Render client requests using various methods, including JSON, HTML, Text, Widgets, and variable dumps. The package supports multiple output formats, allowing you to present data in the most appropriate form for your users.

### 16. Asset Management
Manage and include assets effortlessly during request rendering. Extend the `Layout` class and use the `include_controller` to add and manage assets, ensuring your application resources are well-organized and easily accessible.


## Contributing

Contributions are welcome! If you have suggestions, bug reports, or improvements, please open an issue or submit a pull request on the [GitHub repository](https://github.com/uproid/webapp).

## License

This project is licensed under the [MIT License](../LICENSE).

---

## Installation

### Install WebApp package
   ```bash
   dart pub get webapp
   ```

### Install WebApp CLI
   ```bash
   dart pub global activate webapp
   webapp --version
   ```

   #### Using WebApp CLI
   ```bash
   webapp --help #help
   webapp create --name example # create new project
   webapp get  # get all packages from pub.dev (dart pub get)
   webapp runner # build all models (dart pub run build_runner build)
   webapp run  # Run project
   ```


Feel free to customize and extend the example provided with the package to fully leverage the WebApp package's capabilities in your web development projects.

### Simple WebApp Server example:
   ```dart
   WaConfigs configs = WaConfigs(
  widgetsPath: pathTo("./example/widgets"),
  widgetsType: 'j2.html',
  languagePath: pathTo('./example/languages'),
  port: 8085,
  dbConfig: WaDBConfig(enable: false),
  publicDir: pathTo('./example/public'),
);
WaServer server = WaServer(configs: configs);

final socketManager = SocketManager(
  server,
  event: SocketEvent(
    onConnect: (socket) {
      server.socketManager?.sendToAll(
        "New user connected! count: ${server.socketManager?.countClients}",
        path: "output",
      );
      socket.send(
        {'message': 'Soccuess connect to socket!'},
        path: 'connected',
      );
    },
    onMessage: (socket, data) {},
    onDisconnect: (socket) {
      var count = server.socketManager?.countClients ?? 0;
      server.socketManager?.sendToAll(
        "User disconnected! count: ${count - 1}",
        path: "output",
      );
    },
  ),
  routes: getSocketRoute(),
);

void main() async {
  server.addRouting(getWebRoute);
  server.start().then((value) {
    Console.p("Example app started: http://localhost:${value.port}");
  });
}
   ```

### Email SMTP example:
[Example](/example/)
   ```dart
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

## Routing example:
   ```dart
   Future<List<WebRoute>> getWebRoute(WebRequest rq) async {
      final homeController = HomeController(rq);
      final includeController = IncludeJsController(rq);
      final authController = AuthController(rq);

      var paths = [
         WebRoute(
            path: 'ws',
            methods: RequestMethods.ALL,
            rq: rq,
            index: homeController.socket,
         ),
         WebRoute(
            path: 'app/includes.js',
            methods: RequestMethods.ALL,
            rq: rq,
            index: includeController.index,
         ),
         WebRoute(
            path: 'example',
            rq: rq,
            index: () => rq.redirect('/'),
            ports: [80,8080,443]    /// The allowd ports
            hosts: ['localhost','127.0.0.1', 'example.com']  /// The allowed hostname
            children: [
               WebRoute(
                  path: '/form',
                  methods: RequestMethods.ALL,
                  rq: rq,
                  index: homeController.exampleForm,
               ),
               WebRoute(
                  path: '/cookie',
                  methods: RequestMethods.ONLY_GET,
                  rq: rq,
                  index: homeController.exampleCookie,
               ),
               WebRoute(
                  path: '/panel',
                  methods: RequestMethods.ONLY_GET,
                  rq: rq,
                  index: homeController.examplePanel,
                  auth: authController,
               ),
            ],
         ),
         WebRoute(
            path: 'info',
            extraPath: ['api/info'],
            rq: rq,
            index: homeController.info,
         ),
      ];

      return [
         WebRoute(
            path: '/',
            rq: rq,
            methods: RequestMethods.ALL,
            controller: homeController,
            children: [
            ...paths,
            WebRoute(
               path: 'fa/*',
               extraPath: [
                  'en/*',
                  'nl/*',
               ],
               rq: rq,
               index: homeController.changeLanguage,
            )
            ],
         ),
      ];
   }
   ```