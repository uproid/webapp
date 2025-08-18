import 'dart:convert';

enum TagType {
  single, // Single tag, e.g., <br />
  double, // Double tag, e.g., <div></div>
}

abstract class Tag {
  TagType type = TagType.double;
  String _tag = "html";
  late Map<dynamic, dynamic> attrs;
  late List<Tag> children;

  @override
  String toString() {
    return toHtml();
  }

  Tag({Map<dynamic, dynamic>? attrs, List<Tag>? children}) {
    this.attrs = attrs ?? {};
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

  String toHtml({bool pretty = false, int indent = 0}) {
    final buffer = StringBuffer();
    var attr = "";
    if (attrs.isNotEmpty) {
      attr =
          ' ${attrs.entries.map((e) => '${attrKey(e.key)}="${e.value.toString()}"').join(' ')}';
    }

    // Non-pretty (compact) output — keep original behavior
    if (!pretty) {
      buffer.write('<$_tag$attr');
      if (type == TagType.single) {
        return '$buffer/>';
      } else {
        buffer.write('>');
      }
      for (var child in children) {
        buffer.write(child.toHtml(pretty: pretty));
      }
      buffer.write('</$_tag>');
      return buffer.toString();
    }

    // Pretty output
    final indentStr = '\t' * indent;
    final innerIndentStr = '\t' * (indent + 1);

    if (type == TagType.single) {
      return '$indentStr<$_tag$attr />\n';
    }

    if (children.isEmpty) {
      return '$indentStr<$_tag$attr></$_tag>\n';
    }

    buffer.write('$indentStr<$_tag$attr>\n');

    for (var child in children) {
      var childHtml = child.toHtml(pretty: true);
      childHtml = childHtml.replaceAll('\r\n', '\n');
      var lines = childHtml.split('\n');
      for (var line in lines) {
        if (line.isEmpty) continue;
        buffer.write('$innerIndentStr$line\n');
      }
    }

    buffer.write('$indentStr</$_tag>\n');
    return buffer.toString();
  }
}

class CustomTag extends Tag {
  @override
  CustomTag(
    String tag, {
    super.attrs,
    super.children,
    var type = TagType.double,
  }) {
    _tag = tag;
    this.type = type;
  }
}

abstract class SingleTag extends Tag {
  @override
  get type => TagType.single;
  SingleTag({super.attrs});
}

class Html extends Tag {
  @override
  get _tag => "html";
  Html({super.attrs, super.children});
}

class Head extends Tag {
  @override
  get _tag => "head";
  Head({super.attrs, super.children});
}

class Raw extends Tag {
  String content;

  Raw(this.content);

  @override
  String toHtml({bool pretty = false, int indent = 0}) {
    return content;
  }
}

class Text extends Tag {
  String content;

  Text(this.content);

  @override
  String toHtml({bool pretty = false, int indent = 0}) {
    return htmlEscape.convert(content);
  }
}

class Div extends Tag {
  @override
  get _tag => "div";
  Div({super.attrs, super.children});
}

class Code extends Tag {
  @override
  get _tag => "code";
  Code({super.attrs, super.children});
}

class Body extends Tag {
  @override
  get _tag => "body";
  Body({super.attrs, super.children});
}

class Span extends Tag {
  @override
  get _tag => "span";
  Span({super.attrs, super.children});
}

class A extends Tag {
  @override
  get _tag => "a";
  A({super.attrs, super.children});
}

class B extends Tag {
  @override
  get _tag => "b";
  B({super.attrs, super.children});
}

class I extends Tag {
  @override
  get _tag => "i";
  I({super.attrs, super.children});
}

class U extends Tag {
  @override
  get _tag => "u";
  U({super.attrs, super.children});
}

class P extends Tag {
  @override
  get _tag => "p";
  P({super.attrs, super.children});
}

class Br extends SingleTag {
  @override
  get _tag => "br";
  Br({super.attrs});
}

class Hr extends SingleTag {
  @override
  get _tag => "hr";
  Hr({super.attrs});
}

class Wbr extends SingleTag {
  @override
  get _tag => "wbr";
  Wbr({super.attrs});
}

class Button extends Tag {
  @override
  get _tag => "button";
  Button({super.attrs, super.children});
}

class Input extends SingleTag {
  @override
  get _tag => "input";
  Input({super.attrs});
}

class TextArea extends Tag {
  @override
  get _tag => "textarea";
  TextArea({super.attrs, super.children});
}

class Label extends Tag {
  @override
  get _tag => "label";
  Label({super.attrs, super.children});
}

class Form extends Tag {
  @override
  get _tag => "form";
  Form({super.attrs, super.children});
}

class Select extends Tag {
  @override
  get _tag => "select";
  Select({super.attrs, super.children});
}

class Option extends Tag {
  @override
  get _tag => "option";
  Option({super.attrs, super.children});
}

class Ul extends Tag {
  @override
  get _tag => "ul";
  Ul({super.attrs, super.children});
}

class Li extends Tag {
  @override
  get _tag => "li";
  Li({super.attrs, super.children});
}

class Center extends Tag {
  @override
  get _tag => "center";
  Center({super.attrs, super.children});
}

class Main extends Tag {
  @override
  get _tag => "main";
  Main({super.attrs, super.children});
}

class Footer extends Tag {
  @override
  get _tag => "footer";
  Footer({super.attrs, super.children});
}

class Header extends Tag {
  @override
  get _tag => "header";
  Header({super.attrs, super.children});
}

class Nav extends Tag {
  @override
  get _tag => "nav";
  Nav({super.attrs, super.children});
}

class Section extends Tag {
  @override
  get _tag => "section";
  Section({super.attrs, super.children});
}

class Article extends Tag {
  @override
  get _tag => "article";
  Article({super.attrs, super.children});
}

class Template extends Tag {
  @override
  get _tag => "template";
  Template({super.attrs, super.children});
}

class Aside extends Tag {
  @override
  get _tag => "aside";
  Aside({super.attrs, super.children});
}

class Ol extends Tag {
  @override
  get _tag => "ol";
  Ol({super.attrs, super.children});
}

class H1 extends Tag {
  @override
  get _tag => "h1";
  H1({super.attrs, super.children});
}

class H2 extends Tag {
  @override
  get _tag => "h2";
  H2({super.attrs, super.children});
}

class H3 extends Tag {
  @override
  get _tag => "h3";
  H3({super.attrs, super.children});
}

class H4 extends Tag {
  @override
  get _tag => "h4";
  H4({super.attrs, super.children});
}

class H5 extends Tag {
  @override
  get _tag => "h5";
  H5({super.attrs, super.children});
}

class H6 extends Tag {
  @override
  get _tag => "h6";
  H6({super.attrs, super.children});
}

class H7 extends Tag {
  @override
  get _tag => "h7";
  H7({super.attrs, super.children});
}

class Small extends Tag {
  @override
  get _tag => "small";
  Small({super.attrs, super.children});
}

class Meta extends SingleTag {
  @override
  get _tag => "meta";
  Meta({super.attrs});
}

class Link extends SingleTag {
  @override
  get _tag => "link";
  Link({super.attrs});
}

class Script extends Tag {
  @override
  get _tag => "script";
  Script({super.attrs, super.children});
}

class Noscript extends Tag {
  @override
  get _tag => "noscript";
  Noscript({super.attrs});
}

class Title extends Tag {
  @override
  get _tag => "title";
  Title({super.attrs, super.children});
}

class Style extends Tag {
  @override
  get _tag => "style";
  Style({super.attrs, super.children});
}

class Table extends Tag {
  @override
  get _tag => "table";
  Table({super.attrs, super.children});
}

class Thead extends Tag {
  @override
  get _tag => "thead";
  Thead({super.attrs, super.children});
}

class Tbody extends Tag {
  @override
  get _tag => "tbody";
  Tbody({super.attrs, super.children});
}

class Tr extends Tag {
  @override
  get _tag => "tr";
  Tr({super.attrs, super.children});
}

class Th extends Tag {
  @override
  get _tag => "th";
  Th({super.attrs, super.children});
}

class Td extends Tag {
  @override
  get _tag => "td";
  Td({super.attrs, super.children});
}

class Caption extends Tag {
  @override
  get _tag => "caption";
  Caption({super.attrs, super.children});
}

class Tfoot extends Tag {
  @override
  get _tag => "tfoot";
  Tfoot({super.attrs, super.children});
}

class Comment extends Tag {
  @override
  get _tag => "!--";
  Comment(String content) : super(children: [Raw(content)]);
}

class Svg extends Tag {
  @override
  get _tag => "svg";
  Svg({super.attrs, super.children});
}

class Path extends Tag {
  @override
  get _tag => "path";
  Path({super.attrs, super.children});
}

class Details extends Tag {
  @override
  get _tag => "details";
  Details({super.attrs, super.children});
}

class Summary extends Tag {
  @override
  get _tag => "summary";
  Summary({super.attrs, super.children});
}

class Video extends Tag {
  @override
  get _tag => "video";
  Video({super.attrs, super.children});
}

class Img extends SingleTag {
  @override
  get _tag => "img";
  Img({super.attrs});
}
