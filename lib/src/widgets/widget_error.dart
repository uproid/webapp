import 'package:webapp/src/views/htmler.dart' as h;
import 'package:webapp/wa_server.dart';
import 'package:webapp/src/widgets/wa_string_widget.dart';

/// A widget that provides an HTML layout for displaying error messages.
///
/// The [ErrorWidget] class implements [WaStringWidget] and provides a predefined
/// HTML structure to be used for rendering error messages in the application.
/// It includes styles and structure for displaying error details and stack traces.
class ErrorWidget implements WaStringWidget {
  @override
  final String layout = '';

  @override
  h.Tag Function(Map args)? generateHtml = (Map args) {
    int statusCode = args['statusCode'] ?? 500;
    String title = args['title'] ?? 'Error $statusCode';
    String error = (args['error'] ?? 'No error message available.').toString();
    List stack = args['stack'] ?? [];

    return h.Html(children: [
      h.Head(children: [
        h.Meta(attrs: {'charset': 'utf-8'}),
        h.Meta(attrs: {'http-equiv': 'X-UA-Compatible', 'content': 'IE=edge'}),
        h.Meta(attrs: {
          'name': 'viewport',
          'content': 'width=device-width, initial-scale=1'
        }),
        h.Title(children: [h.Text(title)]),
        h.Style(children: [
          h.Raw("""
            /* ---------- Modern Error Page Styles ---------- */
            :root {
              --color-bg: #0f1115;
              --color-bg-alt: #181b21;
              --color-surface: #1f242c;
              --color-border: #2c333d;
              --color-accent: #3da9fc;
              --color-accent-glow: 75, 170, 255;
              --color-error: #ff4c60;
              --color-error-soft: #ff4c6030;
              --color-warn: #ffc861;
              --color-text: #e6ebf1;
              --color-text-dim: #9aa4b1;
              --radius-sm: 6px;
              --radius-md: 12px;
              --radius-lg: 18px;
              --shadow-sm: 0 2px 4px -1px rgba(0,0,0,.4),0 1px 1px rgba(0,0,0,.25);
              --shadow-md: 0 4px 18px -2px rgba(0,0,0,.55),0 2px 4px rgba(0,0,0,.35);
              --gradient-accent: linear-gradient(135deg,#3da9fc,#6d67ff 60%,#b44cff);
              font-family: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Fira Sans', 'Droid Sans', 'Helvetica Neue', Arial, sans-serif;
            }

            * { box-sizing: border-box; }

            body {
              margin: 0;
              padding: clamp(16px, 3vw, 40px);
              background: radial-gradient(circle at 25% 15%, #1d2430, #0f1115 60%) fixed;
              color: var(--color-text);
              -webkit-font-smoothing: antialiased;
              line-height: 1.45;
            }

            h1 {
              margin: 0 0 .75rem;
              font-size: clamp(2.2rem, 4vw, 3.1rem);
              font-weight: 700;
              letter-spacing: -1px;
              background: var(--gradient-accent);
              -webkit-background-clip: text;
              color: transparent;
              filter: drop-shadow(0 3px 8px rgba(var(--color-accent-glow), .35));
            }

            p { margin: 0 0 1.8rem; font-size: 1.05rem; color: var(--color-text-dim); }

            code, pre { font-family: 'Fira Mono', 'Source Code Pro', monospace; }

            .error-shell {
              max-width: 900px;
              margin: 0 auto;
              background: linear-gradient(145deg, var(--color-bg-alt), var(--color-surface));
              border: 1px solid var(--color-border);
              border-radius: var(--radius-lg);
              padding: clamp(24px, 3vw, 42px);
              box-shadow: var(--shadow-md);
              position: relative;
              overflow: hidden;
            }
            .error-shell::before, .error-shell::after {
              content: '';
              position: absolute;
              width: 420px; height: 420px;
              background: radial-gradient(circle at center, rgba(var(--color-accent-glow), .18), transparent 70%);
              top: -160px; right: -160px;
              pointer-events: none;
              mix-blend-mode: screen;
              filter: blur(8px);
            }
            .error-shell::after { top: auto; bottom: -180px; right: auto; left: -180px; }

            .badge-code {
              display: inline-flex;
              align-items: center;
              gap: .5ch;
              background: var(--color-error-soft);
              color: var(--color-error);
              border: 1px solid var(--color-error);
              font-weight: 600;
              padding: 4px 10px 4px 8px;
              border-radius: 100px;
              font-size: .85rem;
              letter-spacing: .5px;
              box-shadow: 0 0 0 1px rgba(255,76,96,.15), 0 0 0 4px rgba(255,76,96,.07);
              margin: 0 0 1.25rem;
            }

            .error-box {
              background: linear-gradient(135deg, #2a1217, #361a1f 55%, #331319);
              border: 1px solid rgba(255,76,96,.45);
              border-radius: var(--radius-md);
              padding: 16px 18px 14px;
              color: #ffd9de;
              font-size: .9rem;
              line-height: 1.4;
              margin: 0 0 1.5rem;
              position: relative;
              overflow: auto;
              max-height: 260px;
            }
            .error-box::-webkit-scrollbar { width: 10px; }
            .error-box::-webkit-scrollbar-track { background: #00000022; border-radius: 10px; }
            .error-box::-webkit-scrollbar-thumb { background: #ff4c60a8; border-radius: 10px; box-shadow: inset 0 0 0 2px #2b1219; }

            table {
              width: 100%;
              border-collapse: collapse;
              margin: 1.25rem 0 0;
              font-size: .83rem;
              background: var(--color-bg-alt);
              border: 1px solid var(--color-border);
              border-radius: var(--radius-md);
              overflow: hidden;
            }
            thead th {
              background: linear-gradient(90deg, #252c34, #20252c);
              padding: 12px 14px;
              font-size: .78rem;
              letter-spacing: .15ch;
              font-weight: 600;
              text-transform: uppercase;
              color: var(--color-text-dim);
              border-bottom: 1px solid var(--color-border);
            }
            tbody th, tbody td { padding: 9px 12px; border-bottom: 1px solid #262d35; }
            tbody tr:last-child th, tbody tr:last-child td { border-bottom: none; }
            tbody tr:nth-child(even) { background: #1b2026; }
            tbody tr:hover { background: #242b33; }

            .flag { text-align: center; width: 42px; font-size: 1.05rem; }
            .flag[style] { box-shadow: inset 0 0 0 1px #ff4c60aa; border-radius: var(--radius-sm); }

            td code.vscode { color: var(--color-accent); font-weight: 500; }

            a { color: var(--color-accent); text-decoration: none; position: relative; }
            a::after { content:''; position:absolute; left:0; bottom:-2px; height:2px; width:100%; background: var(--gradient-accent); opacity:.35; transition:opacity .25s, transform .25s; transform:translateY(3px); }
            a:hover::after { opacity:.9; transform:translateY(0); }

            /* Subtle fade-in */
            .error-shell, h1, .badge-code, table, .error-box { animation: fadeUp .6s ease; }
            @keyframes fadeUp { from { opacity:0; transform: translateY(14px);} to { opacity:1; transform: translateY(0);} }
          """)
        ])
      ]),
      h.Body(
        attrs: {'style': 'max-width: 100%;'},
        children: [
          h.Div(attrs: {
            'class': 'error-shell'
          }, children: [
            h.Div(
                attrs: {'class': 'badge-code'},
                children: [h.Text('STATUS $statusCode')]),
            h.H1(children: [h.Text("<Error $statusCode />")]),
            h.P(children: [
              h.Text("Oops! Something went wrong. Please try again later."),
            ]),
            if (WaServer.config.isLocalDebug) ...[
              h.Div(
                attrs: {'class': 'error-box'},
                children: [
                  h.Code(
                    attrs: {'style': 'word-break: break-word;'},
                    children: [h.Text(error)],
                  ),
                ],
              ),
              if (stack.isNotEmpty) ...[
                h.Table(
                  attrs: {},
                  children: [
                    h.Thead(children: [
                      h.Tr(children: [
                        h.Th(
                          attrs: {'colspan': '3', 'class': 'text-align:center'},
                          children: [h.Text('Error details')],
                        )
                      ]),
                    ]),
                    h.Tbody(
                      children: [
                        for (var stackItem in stack)
                          if (stackItem.toString().isNotEmpty) ...[
                            h.Tr(
                              children: [
                                h.Th(
                                  attrs: {
                                    'class': 'flag',
                                    if (stackItem
                                        .toString()
                                        .contains('file://'))
                                      'style': 'background-color:#361a1f'
                                  },
                                  children: [
                                    if (stackItem
                                        .toString()
                                        .contains('file://'))
                                      h.Text('⛔')
                                    else if (stackItem
                                        .toString()
                                        .contains('package:webapp'))
                                      h.A(
                                        attrs: {
                                          'target': '_blank',
                                          'title':
                                              'Report to WebApp Developers',
                                          'href':
                                              'https://github.com/uproid/webapp/issues'
                                        },
                                        children: [h.Text('🐛')],
                                      )
                                    else
                                      h.Text('⚪')
                                  ],
                                ),
                                if (stackItem
                                    .toString()
                                    .contains('file://')) ...[
                                  h.Td(
                                    attrs: {
                                      'style': 'color:#ff6f7f; font-weight:500;'
                                    },
                                    children: [
                                      h.Code(
                                        attrs: {
                                          'class': 'vscode',
                                          'style': 'word-break: break-all;'
                                        },
                                        children: [
                                          h.Text(stackItem.toString())
                                        ],
                                      ),
                                    ],
                                  )
                                ] else ...[
                                  h.Td(
                                    attrs: {
                                      'style': 'color: var(--color-text-dim);'
                                    },
                                    children: [h.Text(stackItem.toString())],
                                  )
                                ]
                              ],
                            ),
                          ]
                      ],
                    ),
                  ],
                ),
              ],
            ],
            h.Script(children: [
              h.Raw("""
                (function(){
                  document.querySelectorAll('.vscode').forEach(function(element){
                    var text = element.textContent;
                    var regExp = /\/\/([^)*]+)/;
                    var match = text.match(regExp);
                    if(match && match[1]) {
                      element.innerHTML = '<a href="vscode://file/' + match[1] + '">' + text + '</a>';
                    } else {
                      element.textContent = text;
                    }
                  });
                })();
              """)
            ])
          ])
        ],
      ),
    ]);
  };
}
