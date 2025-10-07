

## 3.0.0
#### Changes Applied to Remove `rq` Parameter from Controllers

##### Summary of Changes

In this project, all controllers and related classes have been updated to use a global `RequestContext` system instead of passing `rq` as a parameter.

##### Main Changes

###### 1. RequestContext Creation
- Created `RequestContext` class in `lib/src/core/request_context.dart`
- Uses Zone-based context for thread-safe request handling
- Provides `RequestContext.current` method for global access to WebRequest

###### 2. WaController Updates
- Removed `rq` parameter from constructor
- Added `rq` getter that uses `RequestContext.current`

###### 3. WaServer Updates
- Added `RequestContext.run()` in request handlers
- Set up request context at the beginning of each request

###### 4. Controller Updates
- `HomeController`: Removed `rq` parameter from constructor
- `AuthController`: Removed `rq` parameter from constructor  
- `HtmlerController`: Removed `rq` parameter from constructor
- `WaApiController`: Removed `rq` parameter from constructor
- `IncludeJsController`: Removed `rq` parameter from constructor

###### 5. Helper Class Updates
- `FormValidator`: Removed `rq` parameter and uses RequestContext
- `WaView`: Removed `rq` parameter and uses RequestContext
- `UIPaging`: Removed `rq` parameter and uses RequestContext
- `AssetManager`: Removed `rq` parameter and uses RequestContext
- `Asset`: Removed `rq` parameter and uses RequestContext
- `DBCollectionFree`: Removed `rq` parameter from all route methods

###### 6. Routing Updates
- Removed passing `rq` to controllers during instantiation
- Converted inline functions to controller methods

###### Benefits of These Changes
  - **Code Simplicity**: No longer need to pass `rq` everywhere
  - **Reduced Repetition**: Eliminated repetitive parameter passing code
  - **Thread Safety**: Zone-based context ensures thread safety
  - **Easy Access**: Simple and global access to WebRequest
---
- Remove `rq` from arguments of `WebRoute`
- Update dependencies
- Update jinja
- Expressions:
  - Ternary operator (condition ? trueValue : falseValue) as alternative to if-else expressions
    ```
    {{ user.isAdmin ? "Admin Panel" : "User Panel" }}
    {{ score > 60 ? "Pass" : "Fail" }}
    ```
  - Null coalescing operator (??) equivalent to or
    ```
    {{ variable ?? "default" }}
    {{ var1 ?? var2 ?? "final" }}
    ```
  - Variable names now support # and @ characters
    ```
    {{ #var }}, {{ var# }}, {{ @variable }}
    ```

## 2.1.1
- Added SSE (Server-Sent Events) support:
  - `renderSSE()` method in WebRequest class for streaming real-time data
  - New `SSE` class for creating Server-Sent Events messages
  - Support for custom headers, content types, and finish events
  - Automatic connection management and proper SSE protocol formatting
- Added new SQL-related form validators:
  - `isUniqueSQLField()` - validates field uniqueness in SQL database tables
  - `hasSqlRelation()` - validates field relations in SQL database tables
  - `checkByRegexp()` - validates fields using regular expression patterns
- Fixed JSON list parsing in WebRequest class
- Fixed localization translation function to properly use WebRequest context
- Added `tryJsonList()` method to WaJson for safer JSON list parsing
- Updated sqler dependency from 1.1.3 to 1.1.4

## 2.1.0
- Added in line dump function for templates `{{ dump(var) }}`
- Added internal Swagger Widget to show documentations
- Fixed analizer reports
- Imoroved examples

## 2.0.3
- Trimming the input values received through GET/POST methods
- Enhancing security measures to mitigate XSS and injection vulnerabilities

## 2.0.2
- Improved `Htmler` tags
- Added `renderTag` to `WebRequest` class
- Added safe filter for templates of jinja

## 2.0.1
- Update Error pages style
- Added Htmler class (beta)
- Updated cli input handlers while running app.
- Fixed bugs

## 2.0.0
- Added Mysql database
- Added Sqler query generator
- Fixed some issus on FormValidators
- Fixed localy filters for templates
- Fixed localy events for templates
- Updated documentaions
- Updated Example and template
- Added Migration functionality for Mysql
- Added cli input handlers while running app.

## 1.1.18
- added $rq so that the current WebRequest can be accessed within templates. This will be useful for developing Local Events.

## 1.1.17 & 1.1.16
- Added custome error layout for `WebRequest`
- Fixes reports of dart analyze

## 1.1.15
- Fixes an error on getAll function of `DBCollectionFree`
- Fixes renew indexes of mongodb collections (`DBCollectionFree`) after run app 
- Add `collation` option for Indexes of `DBCollectionFree`

## 1.1.14
- Add index for fields of `DBCollectionFree`
- Add `Console.json(Object)` function to logs.

## 1.1.12
- Fixes #6 issue, Using `List<ObjectId>` in mongodb collections as a field

## 1.1.11
- Event listeners for insert, update, and delete documents in MongoDB collections for DBCollectionFree.

## 1.1.10
- Fixes issues with DB Collection Free in defualt values, when the form is static

## 1.1.9
- Fixed websocket

## 1.1.8
- Fixed filtering in auto routing DbCollectionFree
- Fixed reported logs of dart analyzer

## 1.1.7
- Added children to auto routing DbCollectionFree

## 1.1.6
- Fixed i18n with parameters

## 1.1.5
- Added default content types for `WebRequest`
- Improved field validators for forms
- Fixed the WaJson to encode and decode Symbol variables.

## 1.1.4
- Fixed issue to start Database when starting project
- Added relation field for Collection Free Model's
- Updated dependencies

## 1.1.3
- Fixed bearer authorization in webrequest
- Auto router paths for api, in Collections Free Models

## 1.1.2
- Added fix
- Update dependencies
- New example regarding video streaming

## 1.1.1
- Resolved several bugs to enhance overall stability.
- Implemented the Collections Free Model (CFM) for MongoDB, streamlining the development of rapid APIs, forms, and validation processes (refer to examples).
- Enhanced existing examples for clearer guidance.
- Integrated the Capp package to facilitate console-based operations.
- Updated all dependencies to their latest versions to ensure compatibility and performance.

## 1.0.34
- Fixed data parsing multipart/form-data while requested emprty
- added tryData function to WebRequest(rq) class to return null or default value as unknown data in requests.
- Improved IncludeController for the DS variable translation (.tr(), .trArray()).

## 1.0.33
- Added build command for CLI:
    ```bash
    webapp build -h
    ```
- Added extentions for File & Directory classes to copy directory and working with file names

## 1.0.32
- Fixed the redirection for external links/URI

## 1.0.31
- Fixed WebApp CLI to create new project in new paths
- Fixed example

## 1.0.30
- Fixed https/http urls for requests
- Fixed layout of example
- Fixed bug Language directory
- UnitTest
- Added --path option to set path for create project in CLI
    ```bash
    webapp create --path ./project_path --name example
    ```
    ```bash
    webapp create -p ./project_path -n example
    ```

## 1.0.26
- Improved the WebApp CLI
    - Fixed bug for OpenApi
    - An example for Swagger has been added: 'https://webapp.uproid.com/swagger'
    - A utility menu has been developed for when the project is running to make controlling the project through the CLI easier.
    ```bash
    webapp run [ENTER]
    help [ENTER]
    
       WEBAPP CLI

       * Press 'r' to Reload  the project                
       * Press 'c' to clear screen                       
       * Press 'i' to write info                         
       * Press 'q' to quit the project                   
    ```

## 1.0.25
- Improved the WebApp CLI

## 1.0.24
- Fixed bug of `webapp cli` in windows platforms

## 1.0.22
- Fixed bugs
- Added webapp cli 
    ```bash
    webapp -help
    webapp create
    webapp get
    webapp run
    webapp -v
    webapp runner
    ```

## 1.0.21

- Fixed bugs.
- Improved the cron job.
- Added new examples.
- Added a `pathsEqual` function to check the equality of paths and endpoints. 

## 1.0.17

- Fixed bugs
- Added watcher to have hot reload in example file ./example/bin/watcher.dart

## 1.0.16

- Expanded `WebRoute` to include port and hostname as part of the routing configuration.

## 1.0.15

- Fixed routing bug for excluded paths
- Fixed bug for dumping variables

## 1.0.14

- Fixed routing issues
- Added variable dumping to the frontend
- Resolved SMTP bugs
- Improved documentation
- Enhanced the UI of error widgets
- Updated examples
- Refined unit tests

## 1.0.10

- Fixed various bugs
- Enhanced SMTP mail sender
- Updated example section

## 1.0.9

- Fixed bugs
- Improved configuration classes
- Updated example section

## 1.0.0

- Initial release