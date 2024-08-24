import 'dart:convert';

import 'package:dartweb/src/render/web_request.dart';
import 'package:dartweb/src/tools/console.dart';
import 'package:path/path.dart' as p;
import 'package:dartweb/dw_server.dart';

class AssetManager {
  List<Asset> includes = [];
  Map<String, Object?> data = {};

  AssetManager(WebRequest rq) {
    includes.insert(
      0,
      Asset(
        rq: rq,
        path: '/app/includes.js',
        cache: AssetCache.never,
      ),
    );
  }

  String getDataJs() {
    try {
      var allData = {};
      for (var asset in js) {
        allData.addAll(asset.data);
      }

      allData.addAll(data);
      var json = jsonEncode(allData);
      return '<script type="text/javascript">;var request = $json;</script>';
    } catch (e) {
      Console.e(e);
    }

    return '';
  }

  List<Asset> get js {
    return getByType(AssetType.js);
  }

  List<Asset> get css {
    return getByType(AssetType.css);
  }

  List<Asset> getByType(AssetType type) {
    return includes.where((asset) => asset.type == type).toList();
  }

  AssetManager addAssets(List<Asset> assets) {
    includes.addAll(assets);
    return this;
  }

  AssetManager addAsset(Asset asset) {
    includes.add(asset);
    return this;
  }

  AssetManager addData(Map<String, Object?> params) {
    data.addAll(params);
    return this;
  }

  AssetManager addNotify({required String text, String type = 'success'}) {
    var notify = (data['notify'] ?? []) as List;
    notify.add({
      'text': text,
      'type': type,
    });
    data['notify'] = notify;
    return this;
  }

  String getCssUI() {
    List<String> result = [];

    for (var c in css) {
      result.add('<link rel="stylesheet" href="${c.url}" />');
    }

    return result.join('\n');
  }

  String getJsUI() {
    List<String> result = [];

    for (var j in js) {
      String attrs = '';
      j.attrs.forEach((key, value) {
        attrs = '$attrs $key="$value"';
      });
      result.add('<script $attrs src="${j.url}"></script>');
    }

    return result.join('\n');
  }
}

class Asset {
  late String _path;
  WebRequest rq;
  AssetType type;
  AssetCache cache = AssetCache.appVersion;
  Map<String, Object> data;
  Map<String, Object> attrs;

  Asset({
    required this.rq,
    required path,
    this.type = AssetType.none,
    this.cache = AssetCache.appVersion,
    this.data = const {},
    this.attrs = const {},
  }) {
    _path = path;
    if (type == AssetType.none) {
      final extention = p.extension(path).toLowerCase();
      switch (extention) {
        case '.js':
          type = AssetType.js;
          break;
        case '.css':
          type = AssetType.css;
          break;
      }
    }
  }

  Asset addData(Map<String, String> params) {
    data.addAll(params);
    return this;
  }

  String get url {
    if (cache == AssetCache.never) {
      return rq.url(
        _path,
        params: {
          'vr': "v1.${DateTime.now().millisecondsSinceEpoch}",
        },
      );
    } else if (cache == AssetCache.appVersion) {
      return rq.url(
        _path,
        params: {
          'vr': "v${DwServer.config.version}",
        },
      );
    } else {
      return rq.url(_path);
    }
  }

  @override
  String toString() {
    return url;
  }
}

enum AssetType { css, js, none }

enum AssetCache { never, cache, appVersion }
