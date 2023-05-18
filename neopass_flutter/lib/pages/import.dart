import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../logger.dart';
import '../protocol.pb.dart' as protocol;
import '../main.dart' as main;
import '../shared_ui.dart' as shared_ui;
import 'new_or_import_profile.dart';

Future<void> importFromBase64(
  BuildContext context,
  main.PolycentricModel state,
  String text,
) async {
  try {
    const prefix = "polycentric://";

    if (!text.startsWith(prefix)) {
      throw const FormatException();
    }

    text = text.substring(prefix.length);

    final decoded = protocol.ExportBundle.fromBuffer(
      base64.decode(text),
    );
    await main.importExportBundle(state.db, decoded);
    await state.mLoadIdentities();

    if (context.mounted) {
      Navigator.push(context,
          MaterialPageRoute<NewOrImportProfilePage>(builder: (context) {
        return const NewOrImportProfilePage();
      }));
    }
  } catch (err) {
    logger.e(err);
    errorDialog(context, err.toString());
  }
}

Future<void> errorDialog(
  BuildContext context,
  String text,
) async {
  await showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(text),
          actions: [
            TextButton(
              child: const Text("Ok"),
              onPressed: () async {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      });
}

class ImportPage extends StatelessWidget {
  const ImportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<main.PolycentricModel>();
    return Scaffold(
      appBar: AppBar(
        title: shared_ui.makeAppBarTitleText("Import"),
      ),
      body: Container(
        padding: shared_ui.scaffoldPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            shared_ui.neopassLogoAndText,
            const SizedBox(height: 120),
            shared_ui.StandardButton(
                actionText: 'Text',
                actionDescription: 'Paste an exported identity',
                icon: Icons.content_copy,
                onPressed: () async {
                  final clip =
                      (await services.Clipboard.getData('text/plain'))?.text;
                  if (clip != null && context.mounted) {
                    await importFromBase64(context, state, clip);
                  }
                }),
            shared_ui.StandardButton(
              actionText: 'QR Code',
              actionDescription: 'Backup from another phone',
              icon: Icons.qr_code,
              onPressed: () async {
                try {
                  final rawScan = await FlutterBarcodeScanner.scanBarcode(
                      "#ff6666", 'Cancel', false, ScanMode.QR);
                  if (rawScan != "-1" && context.mounted) {
                    await importFromBase64(context, state, rawScan);
                  }
                } catch (err) {
                  logger.e(err);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
