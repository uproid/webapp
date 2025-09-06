import 'dart:convert';
import 'package:webapp/wa_server.dart';

enum TagType {
  single, // Single tag, e.g., <br />
  double, // Double tag, e.g., <div></div>
}

abstract class Tag {
  TagType type = TagType.double;
  String _tag = "html";
  String get tagName => _tag;
  late Map<dynamic, dynamic> attrs;
  late List<Tag> children;
  List<dynamic> classes;

  @override
  String toString({bool pretty = false}) {
    return toHtml();
  }

  Tag({
    Map<dynamic, dynamic>? attrs,
    List<Tag>? children,
    this.classes = const [],
  }) {
    this.attrs = attrs ?? {};
    if (classes.isNotEmpty) {
      this.attrs['class'] = classes.join(' ');
    }
    this.children = children ?? [];
  }

  Tag addChild(Tag child) {
    children.add(child);
    return this;
  }

  Tag removeChild(Tag child) {
    children.remove(child);
    return this;
  }

  Tag addAttr(String key, String value) {
    attrs[key] = value;
    return this;
  }

  Tag removeAttr(String key) {
    attrs.remove(key);
    return this;
  }

  Tag clearChildren() {
    children.clear();
    return this;
  }

  Tag addClass(String className) {
    final existingClasses = attrs['class']?.split(' ') ?? [];
    existingClasses.add(className);
    attrs['class'] = existingClasses.join(' ');
    return this;
  }

  Tag removeClass(String className) {
    final existingClasses = attrs['class']?.split(' ') ?? [];
    existingClasses.remove(className);
    attrs['class'] = existingClasses.join(' ');
    return this;
  }

  Tag clearClasses() {
    attrs.remove('class');
    return this;
  }

  Tag addStyle(String property, String value) {
    attrs['style'] = '${attrs['style'] ?? ''}$property: $value; ';
    return this;
  }

  Tag removeStyle(String property) {
    final style = attrs['style'] ?? '';
    final newStyle =
        style.split('; ').where((s) => !s.startsWith('$property:')).join('; ');
    attrs['style'] = newStyle;
    return this;
  }

  Tag clearStyles() {
    attrs.remove('style');
    return this;
  }

  Tag setId(String id) {
    attrs['id'] = id;
    return this;
  }

  Tag setClass(String className) {
    attrs['class'] = className;
    return this;
  }

  Tag setStyle(String property, String value) {
    attrs['style'] = '${attrs['style'] ?? ''}$property: $value; ';
    return this;
  }

  String attrKey(dynamic key) {
    if (key is Symbol) {
      var res = key.toString().split('"')[1].replaceFirst('_', '');
      return res;
    }
    return key.toString();
  }

  String toHtml() {
    final buffer = StringBuffer();
    var attr = "";
    if (attrs.isNotEmpty) {
      attr = attrs.entries
          .map((e) => '${attrKey(e.key)}="${e.value.toString()}"')
          .join(' ');
      attr = ' $attr';
    }

    buffer.write('<$_tag$attr');
    if (type == TagType.single) {
      return '$buffer/>';
    } else {
      buffer.write('>');
    }
    for (var child in children) {
      buffer.write(child.toHtml());
    }
    buffer.write('</$_tag>');
    var res = buffer.toString();
    return res;
  }
}

abstract class JinjaTag extends Tag {
  JinjaTag({super.attrs, super.children, super.classes});
}

class $Jinja extends JinjaTag {
  String command;

  $Jinja(this.command);

  @override
  String toHtml() {
    return '${WaServer.config.blockStart}'
        ' $command '
        '${WaServer.config.blockEnd}';
  }
}

class $JinjaBody extends JinjaTag {
  String commandUp;
  String commandDown;
  $JinjaBody({
    required this.commandUp,
    required super.children,
    required this.commandDown,
  });
  @override
  String toHtml() {
    var res = "${WaServer.config.blockStart}"
        " $commandUp "
        "${WaServer.config.blockEnd}";
    for (var child in children) {
      res += child.toHtml();
    }
    res += "${WaServer.config.blockStart}"
        " $commandDown "
        "${WaServer.config.blockEnd}";
    return res;
  }
}

class $JinjaBlock extends $JinjaBody {
  $JinjaBlock({
    required String blockName,
    List<Tag>? children,
  }) : super(
          commandUp: 'block $blockName',
          commandDown: 'endblock',
          children: children,
        );
}

class $JinjaInclude extends $Jinja {
  $JinjaInclude(String template) : super("include '$template'");
}

class $JinjaVar extends JinjaTag {
  String command;
  $JinjaVar(this.command);

  @override
  String toHtml() {
    return '${WaServer.config.variableStart} $command ${WaServer.config.variableEnd}';
  }
}

class $JinjaComment extends JinjaTag {
  String content;
  $JinjaComment(this.content);

  @override
  String toHtml() {
    return "${WaServer.config.commentStart} $content ${WaServer.config.commentEnd}";
  }
}

class $CustomTag extends Tag {
  @override
  $CustomTag(
    String tag, {
    super.attrs,
    super.children,
    var type = TagType.double,
    super.classes,
  }) {
    _tag = tag;
    this.type = type;
  }
}

abstract class SingleTag extends Tag {
  @override
  get type => TagType.single;
  SingleTag({super.attrs, super.classes});
}

class ArrayTag extends Tag {
  @override
  get _tag => "block";
  ArrayTag({super.children});

  @override
  String toHtml() {
    final buffer = StringBuffer();
    for (var child in children) {
      buffer.write(child.toHtml());
    }
    return buffer.toString();
  }
}

class $Html extends Tag {
  @override
  get _tag => "html";
  $Html({super.attrs, super.children, super.classes});
}

class $Doctype extends SingleTag {
  List<String> params = <String>[];
  @override
  $Doctype([this.params = const ['html']]);

  @override
  String toHtml() {
    return '<!DOCTYPE ${params.join(" ")}>';
  }
}

class $Head extends Tag {
  @override
  get _tag => "head";
  $Head({super.attrs, super.children, super.classes});
}

class $Raw extends Tag {
  String content;

  $Raw(
    this.content, {
    super.classes,
  });

  @override
  String toHtml() {
    return content;
  }
}

class $Text extends Tag {
  String content;

  $Text(this.content, {super.classes});

  @override
  String toHtml() {
    return htmlEscape.convert(content);
  }
}

class $Div extends Tag {
  @override
  get _tag => "div";
  $Div({super.attrs, super.children, super.classes});
}

class $Code extends Tag {
  @override
  get _tag => "code";
  $Code({super.attrs, super.children, super.classes});
}

class $Body extends Tag {
  @override
  get _tag => "body";
  $Body({super.attrs, super.children, super.classes});
}

class $Span extends Tag {
  @override
  get _tag => "span";
  $Span({super.attrs, super.children, super.classes});
}

class $A extends Tag {
  @override
  get _tag => "a";
  $A({super.attrs, super.children, super.classes});
}

class $B extends Tag {
  @override
  get _tag => "b";
  $B({super.attrs, super.children, super.classes});
}

class $I extends Tag {
  @override
  get _tag => "i";
  $I({super.attrs, super.children, super.classes});
}

class $U extends Tag {
  @override
  get _tag => "u";
  $U({super.attrs, super.children, super.classes});
}

class $P extends Tag {
  @override
  get _tag => "p";
  $P({super.attrs, super.children, super.classes});
}

class $Br extends SingleTag {
  @override
  get _tag => "br";
  $Br({super.attrs, super.classes});
}

class $Hr extends SingleTag {
  @override
  get _tag => "hr";
  $Hr({super.attrs, super.classes});
}

class $Wbr extends SingleTag {
  @override
  get _tag => "wbr";
  $Wbr({super.attrs, super.classes});
}

class $Button extends Tag {
  @override
  get _tag => "button";
  $Button({super.attrs, super.children, super.classes});
}

class $Input extends SingleTag {
  @override
  get _tag => "input";
  $Input({super.attrs, super.classes});
}

class $TextArea extends Tag {
  @override
  get _tag => "textarea";
  $TextArea({super.attrs, super.children, super.classes});
}

class $Label extends Tag {
  @override
  get _tag => "label";
  $Label({super.attrs, super.children, super.classes});
}

class $Form extends Tag {
  @override
  get _tag => "form";
  $Form({super.attrs, super.children, super.classes});
}

class $Select extends Tag {
  @override
  get _tag => "select";
  $Select({super.attrs, super.children, super.classes});
}

class $Option extends Tag {
  @override
  get _tag => "option";
  $Option({super.attrs, super.children, super.classes});
}

class $Ul extends Tag {
  @override
  get _tag => "ul";
  $Ul({super.attrs, super.children, super.classes});
}

class $Li extends Tag {
  @override
  get _tag => "li";
  $Li({super.attrs, super.children, super.classes});
}

class $Center extends Tag {
  @override
  get _tag => "center";
  $Center({super.attrs, super.children, super.classes});
}

class $Main extends Tag {
  @override
  get _tag => "main";
  $Main({super.attrs, super.children, super.classes});
}

class $Footer extends Tag {
  @override
  get _tag => "footer";
  $Footer({super.attrs, super.children, super.classes});
}

class $Header extends Tag {
  @override
  get _tag => "header";
  $Header({super.attrs, super.children, super.classes});
}

class $Nav extends Tag {
  @override
  get _tag => "nav";
  $Nav({super.attrs, super.children, super.classes});
}

class $Section extends Tag {
  @override
  get _tag => "section";
  $Section({super.attrs, super.children, super.classes});
}

class $Article extends Tag {
  @override
  get _tag => "article";
  $Article({super.attrs, super.children, super.classes});
}

class $Template extends Tag {
  @override
  get _tag => "template";
  $Template({super.attrs, super.children, super.classes});
}

class $Aside extends Tag {
  @override
  get _tag => "aside";
  $Aside({super.attrs, super.children, super.classes});
}

class $Ol extends Tag {
  @override
  get _tag => "ol";
  $Ol({super.attrs, super.children, super.classes});
}

class $H1 extends Tag {
  @override
  get _tag => "h1";
  $H1({super.attrs, super.children, super.classes});
}

class $H2 extends Tag {
  @override
  get _tag => "h2";
  $H2({super.attrs, super.children, super.classes});
}

class $H3 extends Tag {
  @override
  get _tag => "h3";
  $H3({super.attrs, super.children, super.classes});
}

class $H4 extends Tag {
  @override
  get _tag => "h4";
  $H4({super.attrs, super.children, super.classes});
}

class $H5 extends Tag {
  @override
  get _tag => "h5";
  $H5({super.attrs, super.children, super.classes});
}

class $H6 extends Tag {
  @override
  get _tag => "h6";
  $H6({super.attrs, super.children, super.classes});
}

class $H7 extends Tag {
  @override
  get _tag => "h7";
  $H7({super.attrs, super.children, super.classes});
}

class $Small extends Tag {
  @override
  get _tag => "small";
  $Small({super.attrs, super.children, super.classes});
}

class $Meta extends SingleTag {
  @override
  get _tag => "meta";
  $Meta({super.attrs, super.classes});
}

class $Link extends SingleTag {
  @override
  get _tag => "link";
  $Link({super.attrs, super.classes});
}

class $Script extends Tag {
  @override
  get _tag => "script";
  $Script({super.attrs, super.children, super.classes});
}

class $Noscript extends Tag {
  @override
  get _tag => "noscript";
  $Noscript({super.attrs, super.classes});
}

class $Title extends Tag {
  @override
  get _tag => "title";
  $Title({super.attrs, super.children, super.classes});
}

class $Style extends Tag {
  @override
  get _tag => "style";
  $Style({super.attrs, super.children, super.classes});
}

class $Table extends Tag {
  @override
  get _tag => "table";
  $Table({super.attrs, super.children, super.classes});
}

class $Thead extends Tag {
  @override
  get _tag => "thead";
  $Thead({super.attrs, super.children, super.classes});
}

class $Tbody extends Tag {
  @override
  get _tag => "tbody";
  $Tbody({super.attrs, super.children, super.classes});
}

class $Tr extends Tag {
  @override
  get _tag => "tr";
  $Tr({super.attrs, super.children, super.classes});
}

class $Th extends Tag {
  @override
  get _tag => "th";
  $Th({super.attrs, super.children, super.classes});
}

class $Td extends Tag {
  @override
  get _tag => "td";
  $Td({super.attrs, super.children, super.classes});
}

class $Caption extends Tag {
  @override
  get _tag => "caption";
  $Caption({super.attrs, super.children, super.classes});
}

class $Tfoot extends Tag {
  @override
  get _tag => "tfoot";
  $Tfoot({super.attrs, super.children, super.classes});
}

class $Comment extends Tag {
  Tag content;

  $Comment(this.content)
      : super(
          children: [],
          classes: const [],
        );

  @override
  String toHtml() {
    return '<!-- ${content.toHtml()} -->';
  }
}

class $Svg extends Tag {
  @override
  get _tag => "svg";
  $Svg({super.attrs, super.children, super.classes});
}

class $Path extends Tag {
  @override
  get _tag => "path";
  $Path({super.attrs, super.children, super.classes});
}

class $Details extends Tag {
  @override
  get _tag => "details";
  $Details({super.attrs, super.children, super.classes});
}

class $Summary extends Tag {
  @override
  get _tag => "summary";
  $Summary({super.attrs, super.children, super.classes});
}

class $Video extends Tag {
  @override
  get _tag => "video";
  $Video({super.attrs, super.children, super.classes});
}

class $Img extends SingleTag {
  @override
  get _tag => "img";
  $Img({super.attrs, super.classes});
}

class $Cache extends ArrayTag {
  String _html = '';
  bool get isCached => _html.isNotEmpty;
  String get cachedHtml => _html;

  $Cache({super.children});

  @override
  String toHtml() {
    if (_html.isNotEmpty) return _html;
    _html = super.toHtml();
    return _html;
  }
}

/// Helper class for Jinja tags
/// With this class, you can create Jinja tags easily.
/// Usage:
///   JJ.$include('template.html')
///   JJ.$var('variable_name')
///   JJ.$if('condition', then: [JJ.$var('then_var')], otherwise: [JJ.$var('else_var')])
///   JJ.$for(item: 'item', inList: 'items', body: [JJ.$var('item')])
/// etc.
class JJ {
  static Tag $include(String template) => $JinjaInclude(template);
  static Tag $var(String name) => $JinjaVar(name);
  static Tag $comment(String content) => $JinjaComment(content);

  static Tag $if(
    String condition, {
    List<Tag> then = const [],
    List<Tag> otherwise = const [],
  }) {
    return $JinjaBody(
      commandUp: 'if $condition',
      children: [
        ...then,
        if (otherwise.isNotEmpty) ...[
          $Jinja('else'),
          ...otherwise,
        ]
      ],
      commandDown: 'endif',
    );
  }

  static Tag $shortIf(String condition, String then, [String otherwise = '']) {
    return $JinjaVar(
        '$then if $condition ${otherwise.isEmpty ? '' : 'else $otherwise'}');
  }

  static Tag $for(
      {required String item,
      required String inList,
      List<Tag> body = const []}) {
    return $JinjaBody(
      commandUp: 'for $item in $inList',
      children: body,
      commandDown: 'endfor',
    );
  }
}
