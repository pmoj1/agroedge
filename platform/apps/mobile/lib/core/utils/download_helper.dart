import 'download_helper_stub.dart'
    if (dart.library.js) 'download_helper_web.dart'
    as helper;

/// Save a text/HTML string as a file download on Web. Stubbed on mobile.
void saveAndDownloadFile(String content, String filename) {
  helper.downloadFile(content, filename);
}
