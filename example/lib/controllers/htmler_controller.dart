import 'package:webapp/wa_htmler.dart';
import 'package:webapp/wa_route.dart';

class HtmlerController extends WaController {
  HtmlerController(super.rq);

  @override
  Future<String> index() async {
    return exampleHtmler();
  }

  Future<String> exampleHtmler() async {
    rq.addParam('language', rq.getLanguage());
    rq.addParam('year', DateTime.now().year);

    Tag htmlTag = $Cache(children: [
      $Doctype(),
      $Html(attrs: {
        'lang': rq.getLanguage(),
        'dir': JJ.$var('\$t("dir")'),
      }, children: [
        $Head(
          children: [
            $Meta(attrs: {'charset': 'UTF-8'}),
            $Meta(
              attrs: {
                'name': 'viewport',
                'content': 'width=device-width, initial-scale=1.0',
              },
            ),
            $Title(
                children: [$Text('Htmler Framework - Modern Web Development')]),
            $Link(attrs: {
              'href':
                  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
              'rel': 'stylesheet',
              'integrity':
                  'sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM',
              'crossorigin': 'anonymous'
            }),
            $Style(children: [
              $Raw('''
                  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
                  
                  :root {
                    --md-primary: #E91E63;
                    --md-primary-variant: #C2185B;
                    --md-secondary: #FF4081;
                    --md-secondary-variant: #F50057;
                    --md-accent: #9C27B0;
                    --md-accent-light: #E1BEE7;
                    --md-background: #FAFAFA;
                    --md-surface: #FFFFFF;
                    --md-error: #F44336;
                    --md-on-primary: #FFFFFF;
                    --md-on-secondary: #FFFFFF;
                    --md-on-background: #212121;
                    --md-on-surface: #424242;
                    --md-on-error: #FFFFFF;
                    --md-text-primary: #212121;
                    --md-text-secondary: #757575;
                    --md-divider: #E0E0E0;
                    --md-success: #4CAF50;
                    --md-warning: #FF9800;
                    --md-info: #2196F3;
                    --google-play-pink: #E91E63;
                    --google-play-purple: #9C27B0;
                    --google-play-light-pink: #FCE4EC;
                  }
                  
                  * {
                    box-sizing: border-box;
                  }
                  
                  body {
                    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                    line-height: 1.6;
                    background-color: var(--md-background);
                    color: var(--md-text-primary);
                    margin: 0;
                    padding: 0;
                  }
                  
                  .hero-section {
                    background-color: var(--md-primary);
                    color: var(--md-on-primary);
                    min-height: 80vh;
                    display: flex;
                    align-items: center;
                    position: relative;
                  }
                  
                  .hero-section::before {
                    content: '';
                    position: absolute;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="rgba(255,255,255,0.02)"/><circle cx="75" cy="75" r="1" fill="rgba(255,255,255,0.02)"/><circle cx="50" cy="10" r="0.5" fill="rgba(255,255,255,0.01)"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
                    pointer-events: none;
                  }
                  
                  .hero-title {
                    font-size: 3.5rem;
                    font-weight: 700;
                    letter-spacing: -0.02em;
                    margin-bottom: 1rem;
                    line-height: 1.1;
                  }
                  
                  .hero-subtitle {
                    font-size: 1.25rem;
                    font-weight: 400;
                    opacity: 0.9;
                    margin-bottom: 2.5rem;
                    max-width: 600px;
                  }
                  
                  .section-title {
                    font-size: 2.5rem;
                    font-weight: 600;
                    margin-bottom: 3rem;
                    color: var(--md-text-primary);
                    text-align: center;
                    letter-spacing: -0.01em;
                  }
                  
                  .card {
                    background: var(--md-surface);
                    border: none;
                    border-radius: 12px;
                    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
                    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                    overflow: hidden;
                  }
                  
                  .card:hover {
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 2px 4px rgba(0, 0, 0, 0.06);
                    transform: translateY(-2px);
                  }
                  
                  .stat-card {
                    background: var(--md-surface);
                    border-radius: 16px;
                    box-shadow: 0 2px 8px rgba(233, 30, 99, 0.15);
                    backdrop-filter: blur(10px);
                    border: 1px solid var(--google-play-light-pink);
                  }
                  
                  .stat-number {
                    font-size: 2.5rem;
                    font-weight: 700;
                    color: var(--md-primary);
                  }
                  
                  .navbar-brand {
                    font-weight: 600;
                    font-size: 1.25rem;
                  }
                  
                  .btn {
                    border-radius: 8px;
                    font-weight: 500;
                    padding: 12px 24px;
                    transition: all 0.2s ease;
                    border: none;
                    text-decoration: none;
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                  }
                  
                  .btn-primary {
                    background-color: var(--md-primary);
                    color: var(--md-on-primary);
                  }
                  
                  .btn-primary:hover {
                    background-color: var(--md-primary-variant);
                    transform: translateY(-1px);
                  }
                  
                  .btn-outline-primary {
                    background-color: transparent;
                    border: 2px solid var(--md-primary);
                    color: var(--md-primary);
                  }
                  
                  .btn-outline-primary:hover {
                    background-color: var(--md-primary);
                    color: var(--md-on-primary);
                  }
                  
                  .btn-light {
                    background-color: var(--md-surface);
                    color: var(--md-text-primary);
                  }
                  
                  .btn-outline-light {
                    background-color: transparent;
                    border: 2px solid rgba(255, 255, 255, 0.3);
                    color: var(--md-on-primary);
                  }
                  
                  .btn-outline-light:hover {
                    background-color: rgba(255, 255, 255, 0.1);
                    border-color: rgba(255, 255, 255, 0.5);
                  }
                  
                  .progress {
                    height: 8px;
                    background-color: var(--md-divider);
                    border-radius: 4px;
                    overflow: hidden;
                  }
                  
                  .progress-bar {
                    border-radius: 4px;
                  }
                  
                  .table {
                    border-radius: 8px;
                    overflow: hidden;
                    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
                  }
                  
                  .table th {
                    background-color: var(--md-primary);
                    color: var(--md-on-primary);
                    font-weight: 600;
                    border: none;
                    padding: 16px;
                  }
                  
                  .table td {
                    vertical-align: middle;
                    padding: 16px;
                    border-color: var(--md-divider);
                  }
                  
                  .form-control, .form-select {
                    border: 2px solid var(--md-divider);
                    border-radius: 8px;
                    padding: 12px 16px;
                    background-color: var(--md-surface);
                    transition: border-color 0.2s ease;
                  }
                  
                  .form-control:focus, .form-select:focus {
                    border-color: var(--md-primary);
                    box-shadow: 0 0 0 3px rgba(233, 30, 99, 0.1);
                    outline: none;
                  }
                  
                  .form-label {
                    font-weight: 500;
                    margin-bottom: 8px;
                    color: var(--md-text-primary);
                  }
                  
                  .alert {
                    border: none;
                    border-radius: 8px;
                    padding: 16px;
                    margin: 16px 0;
                  }
                  
                  .alert-info {
                    background-color: rgba(33, 150, 243, 0.1);
                    color: var(--md-info);
                    border-left: 4px solid var(--md-info);
                  }
                  
                  .alert-success {
                    background-color: rgba(76, 175, 80, 0.1);
                    color: var(--md-success);
                    border-left: 4px solid var(--md-success);
                  }
                  
                  .code-block {
                    background-color: #F5F5F5;
                    border: 1px solid var(--md-divider);
                    border-radius: 8px;
                    padding: 20px;
                    font-family: 'Fira Code', 'Consolas', 'Monaco', monospace;
                    font-size: 14px;
                    line-height: 1.5;
                    overflow-x: auto;
                  }
                  
                  .footer {
                    background-color: var(--md-text-primary);
                    color: var(--md-surface);
                  }
                  
                  .footer a {
                    color: rgba(255, 255, 255, 0.7);
                    text-decoration: none;
                    transition: color 0.2s ease;
                  }
                  
                  .footer a:hover {
                    color: var(--md-surface);
                  }
                  
                  .container {
                    max-width: 1200px;
                  }
                  
                  .section {
                    padding: 80px 0;
                  }
                  
                  .card-title {
                    color: var(--md-primary);
                    font-weight: 600;
                    font-size: 1.25rem;
                  }
                  
                  .navbar {
                    background-color: var(--md-surface) !important;
                    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
                  }
                  
                  .navbar-dark .navbar-nav .nav-link {
                    color: var(--md-text-primary);
                  }
                  
                  .list-group-item {
                    border-color: var(--md-divider);
                    transition: background-color 0.2s ease;
                  }
                  
                  .list-group-item:hover {
                    background-color: rgba(233, 30, 99, 0.05);
                  }
                  
                  .badge {
                    font-weight: 500;
                    padding: 6px 12px;
                  }
                  
                  .bg-primary {
                    background-color: var(--md-primary) !important;
                  }
                  
                  .bg-secondary {
                    background-color: var(--md-secondary) !important;
                  }
                  
                  .bg-accent {
                    background-color: var(--md-accent) !important;
                  }
                  
                  .bg-success {
                    background-color: var(--md-success) !important;
                  }
                  
                  .text-primary {
                    color: var(--md-primary) !important;
                  }
                  
                  .text-secondary {
                    color: var(--md-secondary) !important;
                  }
                  
                  .text-accent {
                    color: var(--md-accent) !important;
                  }
                  
                  .text-muted {
                    color: var(--md-text-secondary) !important;
                  }
                  
                  .google-play-card {
                    background: linear-gradient(45deg, var(--google-play-light-pink) 0%, #FFFFFF 50%);
                    border-left: 4px solid var(--md-primary);
                  }
                  
                  @media (max-width: 768px) {
                    .hero-title {
                      font-size: 2.5rem;
                    }
                    
                    .section-title {
                      font-size: 2rem;
                    }
                    
                    .hero-section {
                      min-height: 60vh;
                      text-align: center;
                    }
                    
                    .section {
                      padding: 40px 0;
                    }
                  }
                ''')
            ]),
          ],
        ),
        $Body(children: [
          // Hero Section
          $Section(attrs: {
            'class': 'hero-section'
          }, children: [
            $Div(attrs: {
              'class': 'container'
            }, children: [
              $Div(attrs: {
                'class': 'row align-items-center min-vh-100'
              }, children: [
                $Div(attrs: {
                  'class': 'col-lg-6 mb-5 mb-lg-0'
                }, children: [
                  $H1(
                      attrs: {'class': 'hero-title'},
                      children: [$Text('Htmler Framework')]),
                  $P(attrs: {
                    'class': 'hero-subtitle'
                  }, children: [
                    $Text(
                        'Build modern web applications with type-safe HTML generation. Clean, efficient, and developer-friendly.')
                  ]),
                  $Div(attrs: {
                    'class': 'd-flex gap-3 flex-wrap'
                  }, children: [
                    $Button(
                            attrs: {'class': 'btn btn-light'},
                            children: [$Text('Get Started')])
                        .addAttr('data-language', JJ.$var('language')),
                    $Button(
                        attrs: {'class': 'btn btn-outline-light'},
                        children: [$Text('Documentation')]),
                  ]),
                ]),
                $Div(attrs: {
                  'class': 'col-lg-6'
                }, children: [
                  $Div(attrs: {
                    'class': 'row g-4'
                  }, children: [
                    $Div(attrs: {
                      'class': 'col-6'
                    }, children: [
                      $Div(attrs: {
                        'class': 'stat-card p-4 text-center'
                      }, children: [
                        $Div(
                            attrs: {'class': 'stat-number'},
                            children: [$Text('40+')]),
                        $P(
                            attrs: {'class': 'text-muted mb-0 small'},
                            children: [$Text('HTML Tags')]),
                      ]),
                    ]),
                    $Div(attrs: {
                      'class': 'col-6'
                    }, children: [
                      $Div(attrs: {
                        'class': 'stat-card p-4 text-center'
                      }, children: [
                        $Div(
                            attrs: {'class': 'stat-number'},
                            children: [$Text('100%')]),
                        $P(
                            attrs: {'class': 'text-muted mb-0 small'},
                            children: [$Text('Type Safe')]),
                      ]),
                    ]),
                    $Div(attrs: {
                      'class': 'col-6'
                    }, children: [
                      $Div(attrs: {
                        'class': 'stat-card p-4 text-center'
                      }, children: [
                        $Div(
                            attrs: {'class': 'stat-number'},
                            children: [$Text('0')]),
                        $P(
                            attrs: {'class': 'text-muted mb-0 small'},
                            children: [$Text('Dependencies')]),
                      ]),
                    ]),
                    $Div(attrs: {
                      'class': 'col-6'
                    }, children: [
                      $Div(attrs: {
                        'class': 'stat-card p-4 text-center'
                      }, children: [
                        $Div(
                            attrs: {'class': 'stat-number'},
                            children: [$Text('∞')]),
                        $P(
                            attrs: {'class': 'text-muted mb-0 small'},
                            children: [$Text('Possibilities')]),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ]),
          ]),

          // Navigation
          $Nav(attrs: {
            'class': 'navbar navbar-expand-lg sticky-top'
          }, children: [
            $Div(attrs: {
              'class': 'container'
            }, children: [
              $A(attrs: {
                'class': 'navbar-brand text-primary fw-bold',
                'href': '#'
              }, children: [
                $Text('Htmler')
              ]),
              $Button(attrs: {
                'class': 'navbar-toggler',
                'type': 'button',
                'data-bs-toggle': 'collapse',
                'data-bs-target': '#navbarNav'
              }, children: [
                $Span(attrs: {'class': 'navbar-toggler-icon'}, children: []),
              ]),
              $Div(attrs: {
                'class': 'collapse navbar-collapse',
                'id': 'navbarNav'
              }, children: [
                $Ul(attrs: {
                  'class': 'navbar-nav ms-auto'
                }, children: [
                  $Li(attrs: {
                    'class': 'nav-item'
                  }, children: [
                    $A(attrs: {
                      'class': 'nav-link fw-medium',
                      'href': '#typography'
                    }, children: [
                      $Text('Typography')
                    ]),
                  ]),
                  $Li(attrs: {
                    'class': 'nav-item'
                  }, children: [
                    $A(attrs: {
                      'class': 'nav-link fw-medium',
                      'href': '#forms'
                    }, children: [
                      $Text('Forms')
                    ]),
                  ]),
                  $Li(attrs: {
                    'class': 'nav-item'
                  }, children: [
                    $A(attrs: {
                      'class': 'nav-link fw-medium',
                      'href': '#tables'
                    }, children: [
                      $Text('Tables')
                    ]),
                  ]),
                  $Li(attrs: {
                    'class': 'nav-item'
                  }, children: [
                    $A(attrs: {
                      'class': 'nav-link fw-medium',
                      'href': '#media'
                    }, children: [
                      $Text('Media')
                    ]),
                  ]),
                ]),
              ]),
            ]),
          ]),

          // Main Content
          $Main(attrs: {
            'class': 'section'
          }, children: [
            $Div(attrs: {
              'class': 'container'
            }, children: [
              // Typography Section
              $Section(attrs: {
                'id': 'typography',
                'class': 'mb-5'
              }, children: [
                $H2(
                    attrs: {'class': 'section-title'},
                    children: [$Text('Typography Elements')]),
                $Div(attrs: {
                  'class': 'row g-4'
                }, children: [
                  $Div(attrs: {
                    'class': 'col-lg-4'
                  }, children: [
                    $Div(attrs: {
                      'class': 'card h-100'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card-body'
                      }, children: [
                        $H5(
                            attrs: {'class': 'card-title text-primary mb-4'},
                            children: [$Text('Headings Hierarchy')]),
                        $H1(
                            attrs: {'class': 'h3 mb-2'},
                            children: [$Text('H1 - Main Title')]),
                        $H2(
                            attrs: {'class': 'h4 mb-2'},
                            children: [$Text('H2 - Section Title')]),
                        $H3(
                            attrs: {'class': 'h5 mb-2'},
                            children: [$Text('H3 - Subsection')]),
                        $H4(
                            attrs: {'class': 'h6 mb-2'},
                            children: [$Text('H4 - Minor Heading')]),
                        $H5(
                            attrs: {'class': 'small mb-2'},
                            children: [$Text('H5 - Small Heading')]),
                        $H6(
                            attrs: {'class': 'small mb-3'},
                            children: [$Text('H6 - Smallest Heading')]),
                        $Hr(),
                        $Small(attrs: {
                          'class': 'text-muted'
                        }, children: [
                          $Text(
                              'Perfect semantic hierarchy for SEO and accessibility')
                        ]),
                      ]),
                    ]),
                  ]),
                  $Div(attrs: {
                    'class': 'col-lg-4'
                  }, children: [
                    $Div(attrs: {
                      'class': 'card h-100'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card-body'
                      }, children: [
                        $H5(
                            attrs: {'class': 'card-title text-primary mb-4'},
                            children: [$Text('Text Formatting')]),
                        $P(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Text('This paragraph demonstrates '),
                          $B(children: [$Text('bold text')]),
                          $Text(', '),
                          $I(children: [$Text('italic text')]),
                          $Text(', and '),
                          $U(children: [$Text('underlined text')]),
                          $Text(' formatting options.'),
                        ]),
                        $P(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Text('You can also combine them: '),
                          $B(children: [
                            $I(children: [$Text('bold italic')])
                          ]),
                          $Text(' or '),
                          $U(children: [
                            $B(children: [$Text('underlined bold')])
                          ]),
                          $Text(' text.'),
                        ]),
                        $P(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Text('Inline code example: '),
                          $Code(attrs: {
                            'class': 'bg-light p-1 rounded'
                          }, children: [
                            $Text('const result = htmler.render()')
                          ]),
                          $Text(' within a paragraph.'),
                        ]),
                        $Small(attrs: {
                          'class': 'text-muted'
                        }, children: [
                          $Text(
                              'This is small text that provides additional context or footnotes.')
                        ]),
                      ]),
                    ]),
                  ]),
                  $Div(attrs: {
                    'class': 'col-lg-4'
                  }, children: [
                    $Div(attrs: {
                      'class': 'card h-100'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card-body'
                      }, children: [
                        $H5(
                            attrs: {'class': 'card-title text-primary mb-4'},
                            children: [$Text('Advanced Typography')]),
                        $P(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Text('Modern web typography with '),
                          $Span(
                              attrs: {'class': 'text-accent fw-bold'},
                              children: [$Text('styled text effects')]),
                          $Text(' and beautiful spacing.'),
                        ]),
                        $P(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Text('Use '),
                          $Code(children: [$Text('\$Span')]),
                          $Text(' with custom styles for '),
                          $Span(
                              attrs: {'class': 'badge bg-secondary text-white'},
                              children: [$Text('highlighted text')]),
                          $Text(' or '),
                          $Span(attrs: {
                            'class':
                                'border border-primary text-primary px-2 py-1 rounded'
                          }, children: [
                            $Text('outlined badges')
                          ]),
                          $Text('.'),
                        ]),
                        $P(children: [
                          $Text('Typography is the '),
                          $B(children: [$Text('foundation')]),
                          $Text(' of great web design.'),
                        ]),
                      ]),
                    ]),
                  ]),
                ]),
                $Div(attrs: {
                  'class': 'alert alert-info mt-4'
                }, children: [
                  $P(attrs: {
                    'class': 'mb-0'
                  }, children: [
                    $B(children: [$Text('Pro Tip:')]),
                    $Text(
                        ' All these typography elements are created using Htmler tags, providing type-safe HTML generation with excellent IntelliSense support in your IDE!')
                  ]),
                ]),
              ]),

              // Lists Section
              $Section(attrs: {
                'class': 'mb-5'
              }, children: [
                $H2(
                    attrs: {'class': 'section-title'},
                    children: [$Text('Lists & Navigation')]),
                $Div(attrs: {
                  'class': 'row g-4'
                }, children: [
                  $Div(attrs: {
                    'class': 'col-lg-6'
                  }, children: [
                    $Div(attrs: {
                      'class': 'card h-100'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card-body'
                      }, children: [
                        $H5(
                            attrs: {'class': 'card-title text-primary mb-4'},
                            children: [$Text('Unordered List')]),
                        $Ul(attrs: {
                          'class': 'list-group list-group-flush'
                        }, children: [
                          $Li(attrs: {
                            'class':
                                'list-group-item d-flex justify-content-between align-items-center'
                          }, children: [
                            $Text('First item'),
                            $Span(attrs: {
                              'class': 'badge bg-primary rounded-pill'
                            }, children: [
                              $Text('1')
                            ])
                          ]),
                          $Li(attrs: {
                            'class':
                                'list-group-item d-flex justify-content-between align-items-center'
                          }, children: [
                            $Text('Second item'),
                            $Span(attrs: {
                              'class': 'badge bg-primary rounded-pill'
                            }, children: [
                              $Text('2')
                            ])
                          ]),
                          $Li(attrs: {
                            'class':
                                'list-group-item d-flex justify-content-between align-items-center'
                          }, children: [
                            $Text('Third item'),
                            $Span(attrs: {
                              'class':
                                  'badge bg-secondary rounded-pill text-white'
                            }, children: [
                              $Text('NEW')
                            ])
                          ]),
                          $Li(attrs: {
                            'class':
                                'list-group-item d-flex justify-content-between align-items-center'
                          }, children: [
                            $Text('Fourth item'),
                            $Span(attrs: {
                              'class': 'badge bg-primary rounded-pill'
                            }, children: [
                              $Text('4')
                            ])
                          ]),
                        ]),
                      ]),
                    ]),
                  ]),
                  $Div(attrs: {
                    'class': 'col-lg-6'
                  }, children: [
                    $Div(attrs: {
                      'class': 'card h-100'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card-body'
                      }, children: [
                        $H5(
                            attrs: {'class': 'card-title text-primary mb-4'},
                            children: [$Text('Ordered List')]),
                        $Ol(attrs: {
                          'class': 'list-group list-group-numbered'
                        }, children: [
                          $Li(
                              attrs: {'class': 'list-group-item'},
                              children: [$Text('Setup your environment')]),
                          $Li(
                              attrs: {'class': 'list-group-item'},
                              children: [$Text('Import Htmler library')]),
                          $Li(
                              attrs: {'class': 'list-group-item'},
                              children: [$Text('Create your tags')]),
                          $Li(
                              attrs: {'class': 'list-group-item'},
                              children: [$Text('Render beautiful HTML')]),
                        ]),
                      ]),
                    ]),
                  ]),
                ]),
              ]),

              // Forms Section
              $Section(attrs: {
                'id': 'forms',
                'class': 'mb-5'
              }, children: [
                $H2(
                    attrs: {'class': 'section-title'},
                    children: [$Text('Interactive Form Elements')]),
                $Form(attrs: {
                  'method': 'post',
                  'action': '#'
                }, children: [
                  $Div(attrs: {
                    'class': 'row g-4'
                  }, children: [
                    $Div(attrs: {
                      'class': 'col-lg-4'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card h-100'
                      }, children: [
                        $Div(attrs: {
                          'class': 'card-body'
                        }, children: [
                          $H5(
                              attrs: {'class': 'card-title text-primary mb-4'},
                              children: [$Text('User Information')]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(
                                attrs: {'for': 'name', 'class': 'form-label'},
                                children: [$Text('Full Name')]),
                            $Input(attrs: {
                              'type': 'text',
                              'class': 'form-control',
                              'id': 'name',
                              'name': 'name',
                              'placeholder': 'Enter your full name',
                              'required': 'true',
                            }),
                          ]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(
                                attrs: {'for': 'email', 'class': 'form-label'},
                                children: [$Text('Email Address')]),
                            $Input(attrs: {
                              'type': 'email',
                              'class': 'form-control',
                              'id': 'email',
                              'name': 'email',
                              'placeholder': 'your.email@example.com',
                              'required': 'true',
                            }),
                          ]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(attrs: {
                              'for': 'password',
                              'class': 'form-label'
                            }, children: [
                              $Text('Password')
                            ]),
                            $Input(attrs: {
                              'type': 'password',
                              'class': 'form-control',
                              'id': 'password',
                              'name': 'password',
                              'placeholder': 'Enter secure password',
                              'required': 'true',
                            }),
                          ]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(
                                attrs: {'for': 'phone', 'class': 'form-label'},
                                children: [$Text('Phone Number')]),
                            $Input(attrs: {
                              'type': 'tel',
                              'class': 'form-control',
                              'id': 'phone',
                              'name': 'phone',
                              'placeholder': '+1 (555) 123-4567',
                            }),
                          ]),
                        ]),
                      ]),
                    ]),
                    $Div(attrs: {
                      'class': 'col-lg-4'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card h-100'
                      }, children: [
                        $Div(attrs: {
                          'class': 'card-body'
                        }, children: [
                          $H5(
                              attrs: {'class': 'card-title text-primary mb-4'},
                              children: [$Text('Preferences')]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(attrs: {
                              'for': 'country',
                              'class': 'form-label'
                            }, children: [
                              $Text('Country')
                            ]),
                            $Select(attrs: {
                              'class': 'form-select',
                              'id': 'country',
                              'name': 'country'
                            }, children: [
                              $Option(
                                  attrs: {'value': ''},
                                  children: [$Text('Select your country')]),
                              $Option(
                                  attrs: {'value': 'us'},
                                  children: [$Text('United States')]),
                              $Option(
                                  attrs: {'value': 'ca'},
                                  children: [$Text('Canada')]),
                              $Option(
                                  attrs: {'value': 'uk'},
                                  children: [$Text('United Kingdom')]),
                              $Option(
                                  attrs: {'value': 'de'},
                                  children: [$Text('Germany')]),
                            ]),
                          ]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(attrs: {
                              'for': 'interests',
                              'class': 'form-label'
                            }, children: [
                              $Text('Interests')
                            ]),
                            $Select(attrs: {
                              'class': 'form-select',
                              'id': 'interests',
                              'name': 'interests',
                              'multiple': 'true',
                              'size': '4',
                            }, children: [
                              $Option(
                                  attrs: {'value': 'web-dev'},
                                  children: [$Text('Web Development')]),
                              $Option(
                                  attrs: {'value': 'mobile-dev'},
                                  children: [$Text('Mobile Development')]),
                              $Option(
                                  attrs: {'value': 'design'},
                                  children: [$Text('UI/UX Design')]),
                              $Option(
                                  attrs: {'value': 'data-science'},
                                  children: [$Text('Data Science')]),
                            ]),
                          ]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(attrs: {
                              'for': 'message',
                              'class': 'form-label'
                            }, children: [
                              $Text('Tell us about yourself')
                            ]),
                            $TextArea(attrs: {
                              'class': 'form-control',
                              'id': 'message',
                              'name': 'message',
                              'rows': '3',
                              'placeholder':
                                  'Share your experience, goals, or anything you\'d like us to know...',
                            }, children: []),
                          ]),
                        ]),
                      ]),
                    ]),
                    $Div(attrs: {
                      'class': 'col-lg-4'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card h-100'
                      }, children: [
                        $Div(attrs: {
                          'class': 'card-body'
                        }, children: [
                          $H5(
                              attrs: {'class': 'card-title text-primary mb-4'},
                              children: [$Text('Additional Options')]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(attrs: {
                              'for': 'birthdate',
                              'class': 'form-label'
                            }, children: [
                              $Text('Birth Date')
                            ]),
                            $Input(attrs: {
                              'type': 'date',
                              'class': 'form-control',
                              'id': 'birthdate',
                              'name': 'birthdate',
                            }),
                          ]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(attrs: {
                              'for': 'website',
                              'class': 'form-label'
                            }, children: [
                              $Text('Website URL')
                            ]),
                            $Input(attrs: {
                              'type': 'url',
                              'class': 'form-control',
                              'id': 'website',
                              'name': 'website',
                              'placeholder': 'https://yourwebsite.com',
                            }),
                          ]),
                          $Div(attrs: {
                            'class': 'mb-3'
                          }, children: [
                            $Label(attrs: {
                              'for': 'experience',
                              'class': 'form-label'
                            }, children: [
                              $Text('Years of Experience: '),
                              $Span(
                                  attrs: {'id': 'experienceValue'},
                                  children: [$Text('5')])
                            ]),
                            $Input(attrs: {
                              'type': 'range',
                              'class': 'form-range',
                              'id': 'experience',
                              'name': 'experience',
                              'min': '0',
                              'max': '20',
                              'value': '5',
                            }),
                          ]),
                          $Div(attrs: {
                            'class': 'form-check mb-3'
                          }, children: [
                            $Input(attrs: {
                              'type': 'checkbox',
                              'class': 'form-check-input',
                              'id': 'newsletter',
                              'name': 'newsletter',
                            }),
                            $Label(attrs: {
                              'for': 'newsletter',
                              'class': 'form-check-label'
                            }, children: [
                              $Text('Subscribe to our newsletter')
                            ]),
                          ]),
                          $Div(attrs: {
                            'class': 'form-check mb-4'
                          }, children: [
                            $Input(attrs: {
                              'type': 'checkbox',
                              'class': 'form-check-input',
                              'id': 'terms',
                              'name': 'terms',
                              'required': 'true',
                            }),
                            $Label(attrs: {
                              'for': 'terms',
                              'class': 'form-check-label'
                            }, children: [
                              $Text('I agree to the '),
                              $A(attrs: {
                                'href': '#',
                                'class': 'text-decoration-none'
                              }, children: [
                                $Text('Terms of Service')
                              ]),
                            ]),
                          ]),
                          $Div(attrs: {
                            'class': 'd-grid gap-2'
                          }, children: [
                            $Button(attrs: {
                              'type': 'submit',
                              'class': 'btn btn-primary'
                            }, children: [
                              $Text('Submit Form')
                            ]),
                            $Button(attrs: {
                              'type': 'reset',
                              'class': 'btn btn-outline-secondary'
                            }, children: [
                              $Text('Reset Form')
                            ]),
                          ]),
                        ]),
                      ]),
                    ]),
                  ]),
                ]),
                $Div(attrs: {
                  'class': 'alert alert-info mt-4'
                }, children: [
                  $P(attrs: {
                    'class': 'mb-0'
                  }, children: [
                    $B(children: [$Text('Form Validation:')]),
                    $Text(
                        ' This form showcases various HTML5 input types with built-in validation: '),
                    $Code(children: [$Text('email')]),
                    $Text(', '),
                    $Code(children: [$Text('url')]),
                    $Text(', '),
                    $Code(children: [$Text('tel')]),
                    $Text(', '),
                    $Code(children: [$Text('date')]),
                    $Text(', '),
                    $Code(children: [$Text('range')]),
                    $Text(', and '),
                    $Code(children: [$Text('required')]),
                    $Text(' attributes.')
                  ]),
                ]),
              ]),

              // Tables Section
              $Section(attrs: {
                'id': 'tables',
                'class': 'mb-5'
              }, children: [
                $H2(
                    attrs: {'class': 'section-title'},
                    children: [$Text('Table Elements')]),
                $Div(attrs: {
                  'class': 'card'
                }, children: [
                  $Div(attrs: {
                    'class': 'card-body'
                  }, children: [
                    $H5(attrs: {
                      'class': 'card-title text-primary mb-4'
                    }, children: [
                      $Text('Popular Programming Languages (2024)')
                    ]),
                    $Div(attrs: {
                      'class': 'table-responsive'
                    }, children: [
                      $Table(attrs: {
                        'class': 'table table-striped table-hover'
                      }, children: [
                        $Thead(children: [
                          $Tr(children: [
                            $Th(
                                attrs: {'scope': 'col'},
                                children: [$Text('Rank')]),
                            $Th(
                                attrs: {'scope': 'col'},
                                children: [$Text('Language')]),
                            $Th(
                                attrs: {'scope': 'col'},
                                children: [$Text('Popularity %')]),
                            $Th(
                                attrs: {'scope': 'col'},
                                children: [$Text('Primary Use')]),
                            $Th(
                                attrs: {'scope': 'col'},
                                children: [$Text('Year Created')]),
                          ]),
                        ]),
                        $Tbody(children: [
                          $Tr(children: [
                            $Td(children: [
                              $Span(
                                  attrs: {'class': 'badge bg-primary'},
                                  children: [$Text('1')])
                            ]),
                            $Td(children: [
                              $B(children: [$Text('JavaScript')])
                            ]),
                            $Td(children: [$Text('69.7%')]),
                            $Td(children: [$Text('Web Development')]),
                            $Td(children: [$Text('1995')]),
                          ]),
                          $Tr(children: [
                            $Td(children: [
                              $Span(
                                  attrs: {'class': 'badge bg-primary'},
                                  children: [$Text('2')])
                            ]),
                            $Td(children: [
                              $B(children: [$Text('Python')])
                            ]),
                            $Td(children: [$Text('51.8%')]),
                            $Td(children: [$Text('Data Science, AI')]),
                            $Td(children: [$Text('1991')]),
                          ]),
                          $Tr(children: [
                            $Td(children: [
                              $Span(
                                  attrs: {'class': 'badge bg-primary'},
                                  children: [$Text('3')])
                            ]),
                            $Td(children: [
                              $B(children: [$Text('Dart')])
                            ]),
                            $Td(children: [$Text('6.02%')]),
                            $Td(children: [$Text('Flutter, Web Apps')]),
                            $Td(children: [$Text('2011')]),
                          ]),
                          $Tr(children: [
                            $Td(children: [
                              $Span(
                                  attrs: {'class': 'badge bg-primary'},
                                  children: [$Text('4')])
                            ]),
                            $Td(children: [
                              $B(children: [$Text('Java')])
                            ]),
                            $Td(children: [$Text('40.2%')]),
                            $Td(children: [$Text('Enterprise, Android')]),
                            $Td(children: [$Text('1995')]),
                          ]),
                        ]),
                      ]),
                    ]),
                    $Small(attrs: {
                      'class': 'text-muted'
                    }, children: [
                      $I(children: [
                        $Text(
                            'Data source: Stack Overflow Developer Survey 2024')
                      ]),
                    ]),
                  ]),
                ]),
              ]),

              // Media Section
              $Section(attrs: {
                'id': 'media',
                'class': 'mb-5'
              }, children: [
                $H2(
                    attrs: {'class': 'section-title'},
                    children: [$Text('Media & Visual Elements')]),
                $Div(attrs: {
                  'class': 'row g-4'
                }, children: [
                  $Div(attrs: {
                    'class': 'col-lg-4'
                  }, children: [
                    $Div(attrs: {
                      'class': 'card h-100'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card-body'
                      }, children: [
                        $H5(
                            attrs: {'class': 'card-title text-primary mb-4'},
                            children: [$Text('Progress Indicators')]),
                        $Div(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Label(
                              attrs: {'class': 'form-label small'},
                              children: [$Text('HTML Skills')]),
                          $Div(attrs: {
                            'class': 'progress'
                          }, children: [
                            $Div(attrs: {
                              'class': 'progress-bar bg-primary',
                              'role': 'progressbar',
                              'style': 'width: 90%',
                              'aria-valuenow': '90',
                              'aria-valuemin': '0',
                              'aria-valuemax': '100'
                            }, children: [
                              $Text('90%')
                            ]),
                          ]),
                        ]),
                        $Div(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Label(
                              attrs: {'class': 'form-label small'},
                              children: [$Text('CSS Skills')]),
                          $Div(attrs: {
                            'class': 'progress'
                          }, children: [
                            $Div(attrs: {
                              'class': 'progress-bar bg-success',
                              'role': 'progressbar',
                              'style': 'width: 85%',
                              'aria-valuenow': '85',
                              'aria-valuemin': '0',
                              'aria-valuemax': '100'
                            }, children: [
                              $Text('85%')
                            ]),
                          ]),
                        ]),
                        $Div(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Label(
                              attrs: {'class': 'form-label small'},
                              children: [$Text('Dart Skills')]),
                          $Div(attrs: {
                            'class': 'progress'
                          }, children: [
                            $Div(attrs: {
                              'class': 'progress-bar bg-warning',
                              'role': 'progressbar',
                              'style': 'width: 95%',
                              'aria-valuenow': '95',
                              'aria-valuemin': '0',
                              'aria-valuemax': '100'
                            }, children: [
                              $Text('95%')
                            ]),
                          ]),
                        ]),
                      ]),
                    ]),
                  ]),
                  $Div(attrs: {
                    'class': 'col-lg-8'
                  }, children: [
                    $Div(attrs: {
                      'class': 'card h-100'
                    }, children: [
                      $Div(attrs: {
                        'class': 'card-body'
                      }, children: [
                        $H5(
                            attrs: {'class': 'card-title text-primary mb-4'},
                            children: [$Text('Interactive Elements')]),
                        $Details(attrs: {
                          'class': 'mb-3'
                        }, children: [
                          $Summary(
                              attrs: {'class': 'btn btn-outline-primary'},
                              children: [$Text('Click to expand details')]),
                          $Div(attrs: {
                            'class': 'mt-3 p-3 bg-light rounded'
                          }, children: [
                            $P(children: [
                              $Text(
                                  'This content is hidden by default and can be toggled using the '),
                              $Code(children: [$Text('\$Details')]),
                              $Text(' and '),
                              $Code(children: [$Text('\$Summary')]),
                              $Text(
                                  ' tags. It\'s perfect for FAQs, documentation, and collapsible content.'),
                            ]),
                            $Ul(attrs: {
                              'class': 'list-unstyled'
                            }, children: [
                              $Li(attrs: {
                                'class': 'mb-1'
                              }, children: [
                                $Span(
                                    attrs: {'class': 'text-success me-2'},
                                    children: [$Text('✓')]),
                                $Text('Semantic HTML')
                              ]),
                              $Li(attrs: {
                                'class': 'mb-1'
                              }, children: [
                                $Span(
                                    attrs: {'class': 'text-success me-2'},
                                    children: [$Text('✓')]),
                                $Text('Accessible by default')
                              ]),
                              $Li(attrs: {
                                'class': 'mb-1'
                              }, children: [
                                $Span(
                                    attrs: {'class': 'text-success me-2'},
                                    children: [$Text('✓')]),
                                $Text('No JavaScript required')
                              ]),
                            ]),
                          ]),
                        ]),
                      ]),
                    ]),
                  ]),
                ]),
              ]),

              // Code Examples Section
              $Section(attrs: {
                'class': 'mb-5'
              }, children: [
                $H2(
                    attrs: {'class': 'section-title'},
                    children: [$Text('Code Examples')]),
                $Div(attrs: {
                  'class': 'card'
                }, children: [
                  $Div(attrs: {
                    'class': 'card-body'
                  }, children: [
                    $H5(
                        attrs: {'class': 'card-title text-primary mb-4'},
                        children: [$Text('Htmler Usage Example')]),
                    $P(children: [
                      $Text(
                          'Here\'s how you can create elements using Htmler tags:'),
                    ]),
                    $Div(attrs: {
                      'class': 'code-block'
                    }, children: [
                      $Code(children: [
                        $Text('''// Creating a button with Htmler
\$Button(attrs: {
  'type': 'submit',
  'class': 'btn btn-primary',
}, children: [
  \$Text('Click me!')
])

// Creating a card layout
\$Div(attrs: {'class': 'card'}, children: [
  \$Div(attrs: {'class': 'card-body'}, children: [
    \$H5(attrs: {'class': 'card-title'}, children: [
      \$Text('Card Title')
    ]),
    \$P(attrs: {'class': 'card-text'}, children: [
      \$Text('Card content goes here...')
    ]),
  ]),
])'''),
                      ]),
                    ]),
                  ]),
                ]),
              ]),

              // Jinja Integration Section
              $Section(attrs: {
                'class': 'mb-5'
              }, children: [
                $H2(
                    attrs: {'class': 'section-title'},
                    children: [$Text('Jinja Integration')]),
                $Div(attrs: {
                  'class': 'card'
                }, children: [
                  $Div(attrs: {
                    'class': 'card-body'
                  }, children: [
                    $H5(
                        attrs: {'class': 'card-title text-primary mb-4'},
                        children: [$Text('Dynamic Content with Jinja')]),
                    $P(children: [
                      $Text('Current language: '),
                      $B(children: [JJ.$var('language')]),
                    ]),
                    $P(children: [
                      $Text('Current year: '),
                      $B(children: [JJ.$var('year')]),
                    ]),
                    $Hr(),
                    $H6(children: [$Text('Conditional Rendering')]),
                    JJ.$if('user', then: [
                      $Div(attrs: {
                        'class': 'alert alert-success'
                      }, children: [
                        $Text('Welcome back, '),
                        $B(children: [JJ.$var('user.name')]),
                        $Text('!'),
                      ]),
                    ], otherwise: [
                      $Div(attrs: {
                        'class': 'alert alert-info'
                      }, children: [
                        $Text('Please '),
                        $A(
                            attrs: {'href': '/login', 'class': 'alert-link'},
                            children: [$Text('log in')]),
                        $Text(' to continue.'),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ]),
          ]),

          // Footer
          $Footer(attrs: {
            'class': 'footer py-5'
          }, children: [
            $Div(attrs: {
              'class': 'container'
            }, children: [
              $Div(attrs: {
                'class': 'row'
              }, children: [
                $Div(attrs: {
                  'class': 'col-lg-8 mx-auto text-center'
                }, children: [
                  $H3(
                      attrs: {'class': 'text-white mb-4'},
                      children: [$Text('Htmler Framework')]),
                  $P(attrs: {
                    'class': 'mb-4 text-white-50'
                  }, children: [
                    $Text('Building the future of web development with '),
                    $Span(
                        attrs: {'class': 'text-white fw-medium'},
                        children: [$Text('Dart WebApp Framework')]),
                    $Text(' & '),
                    $Span(
                        attrs: {'class': 'text-white fw-medium'},
                        children: [$Text('Htmler Library')]),
                  ]),
                  $Div(attrs: {
                    'class':
                        'd-flex gap-3 justify-content-center flex-wrap mb-4'
                  }, children: [
                    $A(attrs: {
                      'href': '#',
                      'class': 'btn btn-outline-light btn-sm'
                    }, children: [
                      $Text('Documentation')
                    ]),
                    $A(attrs: {
                      'href': '#',
                      'class': 'btn btn-outline-light btn-sm'
                    }, children: [
                      $Text('GitHub')
                    ]),
                    $A(attrs: {
                      'href': '#',
                      'class': 'btn btn-outline-light btn-sm'
                    }, children: [
                      $Text('Community')
                    ]),
                  ]),
                  $Hr(attrs: {'class': 'my-4 border-secondary'}),
                  $P(attrs: {
                    'class': 'small text-white-50 mb-0'
                  }, children: [
                    $Text(
                        '© ${DateTime.now().year} WebApp Framework. Made with ❤️ for developers.'),
                  ]),
                ]),
              ]),
            ]),
          ]),

          // Bootstrap JavaScript
          $Script(attrs: {
            'src':
                'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js',
            'integrity':
                'sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz',
            'crossorigin': 'anonymous'
          }, children: []),

          // Additional JavaScript for interactivity
          $Script(children: [
            $Raw('''
                document.addEventListener('DOMContentLoaded', function() {
                  // Range input update
                  const experienceRange = document.getElementById('experience');
                  const experienceValue = document.getElementById('experienceValue');
                  if (experienceRange && experienceValue) {
                    experienceRange.addEventListener('input', function() {
                      experienceValue.textContent = this.value;
                    });
                  }
                });
              ''')
          ]),

          // Comment for demonstration
          $Comment($Text(
              'This professional HTML was generated entirely using Htmler tags with Bootstrap 5.3!')),
        ]),
      ])
    ]);

    return rq.renderTag(tag: htmlTag, pretty: false);
  }
}
