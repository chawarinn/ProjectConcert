// lib/Page/Member/TicketWebviewPage.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketWebviewPage extends StatefulWidget {
  final String url;
  const TicketWebviewPage({super.key, required this.url});

  @override
  State<TicketWebviewPage> createState() => _TicketWebviewPageState();
}

class _TicketWebviewPageState extends State<TicketWebviewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
         backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        title: Text(
          'Ticket',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
