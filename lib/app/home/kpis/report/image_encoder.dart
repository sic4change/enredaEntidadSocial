/// Codificación de las capturas de las gráficas para el informe.
///
/// Import condicional: en web se resuelve a [image_encoder_web.dart], que
/// genera un JPEG con el canvas del navegador (asíncrono y sin bloquear la
/// interfaz, y que el PDF incrusta sin tener que decodificarlo); en el resto
/// de plataformas a [image_encoder_io.dart], que usa PNG.
export 'image_encoder_io.dart'
    if (dart.library.html) 'image_encoder_web.dart';
