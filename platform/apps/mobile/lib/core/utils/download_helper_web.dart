// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

void downloadFile(String content, String filename) {
  // Use JS interop to create a download link and trigger click in the browser
  js.context.callMethod('eval', [
    "var element = document.createElement('a');"
        "element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(unescape(encodeURIComponent('''$content'''))));"
        "element.setAttribute('download', '$filename');"
        "element.style.display = 'none';"
        "document.body.appendChild(element);"
        "element.click();"
        "document.body.removeChild(element);",
  ]);
}
