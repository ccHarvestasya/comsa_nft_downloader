import 'dart:io';

Future main() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('Server started on port: ${server.port}');

  await for (HttpRequest request in server) {
    handleRequest(request);
  }
}

void handleRequest(HttpRequest request) {
  print('Received request: ${request.method} ${request.uri.path}');

  try {
    // クエリパラメータ取得
    String? mosaicId = request.uri.queryParameters['mosaicId'];

    if (mosaicId == null || mosaicId.isEmpty) {
      throw Exception('mosaicIdが指定されていません');
    }

    StatisticsServiceHttp ssHttp = StatisticsServiceHttp();
    await ssHttp.init();

    ComsaNft comsaNft = ComsaNft();
    Uint8List nftData = await comsaNft.decoder(mosaicId: mosaicId);
    ComsaNftInfoDetail comsaNftInfoDetail = comsaNft.comsaNftInfoDetail!;



    request.response
      ..headers.contentType = ContentType('text', 'plain', charset: 'utf-8')
      ..write('Hello, World!')
      ..close();
  } catch (e) {
    print(e);
    request.response
      ..statusCode = HttpStatus.badRequest
      ..write("error")
      ..close();
  }
}
