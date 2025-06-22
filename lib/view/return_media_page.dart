import 'package:flutter/material.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';
import 'package:media_management_track/viewmodel/return_media_viewmodel.dart';

class ReturnMediaPage extends StatefulWidget {
  const ReturnMediaPage({Key? key}) : super(key: key);

  @override
  State<ReturnMediaPage> createState() => _ReturnMediaPageState();
}

class _ReturnMediaPageState extends State<ReturnMediaPage> {
  String? result;
  late Key scannerKey;
late FlutterWebQrcodeScanner scanner;


  @override
  void initState() {
    super.initState();
    scanner = buildScanner();
  }

  FlutterWebQrcodeScanner buildScanner() {
  scannerKey = UniqueKey(); // generate key baru
  return FlutterWebQrcodeScanner(
    key: scannerKey,
    cameraDirection: CameraDirection.back,
    stopOnFirstResult: true,
    onGetResult: (res) {
      setState(() => result = res);
      onQrScanned(res);
    },
  );
}

void onQrScanned(String text) async {
  try {
    await ReturnMediaViewModel().returnMedia(text);

    // Tampilkan ceklis besar di tengah
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: const Icon(
            Icons.check_circle,
            size: 120,
            color: Colors.greenAccent,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Hilangkan setelah 2 detik
    await Future.delayed(const Duration(seconds: 2));
    overlayEntry.remove();

    // Optional: reset scanner atau tampilkan snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengembalian media berhasil!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}


  void restartScan() {
    setState(() {
      result = null;
      scanner = buildScanner();
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kotak scanner 300x300 fix
            SizedBox(
              width: 300,
              height: 300,
              child: scanner,
            ),
            const SizedBox(height: 20),
            Text(
              result == null ? 'Arahkan kamera ke QR code' : 'Hasil: $result',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (result != null)
              ElevatedButton(
                onPressed: restartScan,
                child: const Text('Scan Ulang'),
              ),
          ],
        ),
      ),
    ),
  );
}

}
