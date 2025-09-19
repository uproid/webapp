import 'package:webapp/src/views/htmler.dart';
import 'package:webapp/wa_ui.dart';

class WidgetSwagger extends WaStringWidget {
  @override
  Tag Function(Map<dynamic, dynamic>)? get generateHtml => (Map args) {
        final String url = args['url'] ?? '/api/docs';
        final String title = args['title'] ?? 'API Documentation';

        Tag html = ArrayTag(
          children: [
            $Doctype(),
            $Html(attrs: {
              'lang': 'en'
            }, children: [
              $Head(children: [
                $Meta(attrs: {'charset': 'UTF-8'}),
                $Meta(attrs: {
                  'name': 'viewport',
                  'content': 'width=device-width, initial-scale=1.0'
                }),
                $Title(children: [$Text(title)]),
                $Link(attrs: {
                  'rel': 'stylesheet',
                  'href':
                      'https://unpkg.com/swagger-ui-dist@5.0.0/swagger-ui.css'
                }),
                $Style(children: [$Raw(_getCustomCSS())]),
              ]),
              $Body(children: [
                // Header
                $Header(classes: [
                  'swagger-header'
                ], children: [
                  $Div(classes: [
                    'container'
                  ], children: [
                    $H1(children: [$Text(title)]),
                    $P(children: [
                      $Text(
                          'Interactive API documentation powered by Swagger UI')
                    ])
                  ])
                ]),

                // Main content
                $Main(children: [
                  $Div(attrs: {'id': 'swagger-ui'})
                ]),

                // Scripts
                $Script(attrs: {
                  'src':
                      'https://unpkg.com/swagger-ui-dist@5.0.0/swagger-ui-bundle.js'
                }),
                $Script(attrs: {
                  'src':
                      'https://unpkg.com/swagger-ui-dist@5.0.0/swagger-ui-standalone-preset.js'
                }),
                $Script(children: [$Raw(_getSwaggerInitJS(url))])
              ])
            ])
          ],
        );

        return html;
      };

  String _getCustomCSS() {
    return '''
      body {
        margin: 0;
        padding: 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        background-color: #fafafa;
      }

      .swagger-header {
        background: linear-gradient(135deg, #89bf04 0%, #7ba203 100%);
        color: white;
        padding: 20px 0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }

      .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
      }

      .swagger-header h1 {
        margin: 0 0 10px 0;
        font-size: 2.5rem;
        font-weight: 600;
      }

      .swagger-header p {
        margin: 0;
        opacity: 0.9;
        font-size: 1.1rem;
      }

      main {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
      }

      #swagger-ui {
        min-height: 400px;
      }

      /* Override Swagger UI styles */
      .swagger-ui .topbar {
        display: none !important;
      }

      .swagger-ui .info {
        margin: 0 !important;
      }

      @media (max-width: 768px) {
        .swagger-header h1 {
          font-size: 2rem;
        }
        
        .container {
          padding: 0 15px;
        }
        
        main {
          padding: 15px;
        }
      }
    ''';
  }

  String _getSwaggerInitJS(String url) {
    return '''
      window.addEventListener('load', function() {
        if (typeof SwaggerUIBundle === 'undefined') {
          document.getElementById('swagger-ui').innerHTML = 
            '<div style="padding: 20px; text-align: center; color: #d32f2f;"><h3>Error Loading Swagger UI</h3><p>Failed to load Swagger UI libraries. Please check your internet connection.</p></div>';
          return;
        }

        try {
          SwaggerUIBundle({
            url: '$url',
            dom_id: '#swagger-ui',
            deepLinking: true,
            presets: [
              SwaggerUIBundle.presets.apis,
              SwaggerUIStandalonePreset
            ],
            plugins: [
              SwaggerUIBundle.plugins.DownloadUrl
            ],
            layout: "StandaloneLayout",
            validatorUrl: null,
            docExpansion: "list",
            operationsSorter: "alpha",
            tagsSorter: "alpha",
            filter: true,
            showExtensions: true,
            showCommonExtensions: true,
            defaultModelsExpandDepth: 1,
            defaultModelExpandDepth: 1,
            displayOperationId: false,
            displayRequestDuration: true,
            tryItOutEnabled: true,
            onComplete: function() {
              console.log('Swagger UI loaded successfully');
            },
            onFailure: function(error) {
              console.error('Swagger UI error:', error);
              document.getElementById('swagger-ui').innerHTML = 
                '<div style="padding: 20px; text-align: center; color: #d32f2f;"><h3>Error Loading API Documentation</h3><p>' + 
                (error.message || 'Failed to load API specification') + 
                '</p><p>API URL: <code>$url</code></p></div>';
            }
          });
        } catch (error) {
          console.error('Error initializing Swagger UI:', error);
          document.getElementById('swagger-ui').innerHTML = 
            '<div style="padding: 20px; text-align: center; color: #d32f2f;"><h3>Initialization Error</h3><p>' + 
            error.message + '</p></div>';
        }
      });
    ''';
  }
}
