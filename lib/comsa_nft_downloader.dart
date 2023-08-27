import 'dart:io';
import 'dart:typed_data';

import 'package:symbol_ddk/infra/statistics_service_http.dart';
import 'package:symbol_ddk/model/comsa_nft/comsa_nft_info_detail.dart';
import 'package:symbol_ddk/util/comsa_nft.dart';

Future main() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('Server started on port: ${server.port}');

  await for (HttpRequest request in server) {
    handleRequest(request);
  }
}

Future<void> handleRequest(HttpRequest request) async {
  print('Received request: ${request.method} ${request.uri.path}');

  try {
    if (request.uri.path != '/') {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write("notFound")
        ..close();
      return;
    }

    // クエリパラメータ取得
    String? mosaicId = request.uri.queryParameters['mosaicId'];
    if (mosaicId == null || mosaicId.isEmpty) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write("error")
        ..close();
      return;
    }

    try {
      // StatisticsServices初期化
      StatisticsServiceHttp ssHttp = StatisticsServiceHttp();
      await ssHttp.init();
      // ComsaNFTデコード
      ComsaNft comsaNft = ComsaNft();
      Uint8List nftData = await comsaNft.decoder(mosaicId: mosaicId);
      ComsaNftInfoDetail comsaNftInfoDetail = comsaNft.comsaNftInfoDetail!;

      // コンテンツタイプ
      List<String> contentType = comsaNftInfoDetail.mimeType.split('/');
      String primaryType = contentType[0];
      String subType = contentType[1];
      print('$primaryType/$subType');

      // HTTPレスポンス
      request.response
        ..headers.contentType = ContentType(primaryType, subType)
        ..add(nftData)
        ..close();
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.notFound
        ..write("notFound")
        ..close();
    }
  } catch (e) {
    print(e);
    request.response
      ..statusCode = HttpStatus.badRequest
      ..write("error")
      ..close();
  }
}
