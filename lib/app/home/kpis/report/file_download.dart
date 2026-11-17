/// Descarga de un fichero generado en memoria.
///
/// Import condicional: en web se resuelve a [file_download_web.dart] (Blob +
/// enlace con `download`); en el resto de plataformas a
/// [file_download_io.dart], que lo guarda en Documentos y lo abre.
export 'file_download_io.dart'
    if (dart.library.html) 'file_download_web.dart';
