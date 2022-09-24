import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key, required this.onDetect}) : super(key: key);
  final void Function(Barcode barcode) onDetect;

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // Debounce decoding please!
  bool gotValidQR = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    // When we navigate away we need to make sure the camera can be re-created on mount again
    setState(() {
      gotValidQR = false;
      this.controller = controller;
      controller.resumeCamera();
    });
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Debounce them!
      if (gotValidQR) {
        return;
      }
      setState(() {
        gotValidQR = true;
        result = scanData;
        widget.onDetect(scanData);
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
