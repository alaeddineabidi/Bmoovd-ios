import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('QR-Code-Scanner',style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700,color: Color(0xffE6E7E9),fontSize: 16))),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/icons/back_arrow.png"),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
         
        ],
      ),
    );
  }
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      // Check if the scanned data is a URL
      if (result != null && _isURL(result!.code)) {
        _launchURL(result!.code);
      }
    });
  }

  bool _isURL(String? str) {
    if (str == null) return false;
    final urlPattern = r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([/\w \.-]*)*\/?$';
    return RegExp(urlPattern).hasMatch(str);
  }

  void _launchURL(String? url) async {
    if (await canLaunch(url!)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir l\'URL $url';
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
