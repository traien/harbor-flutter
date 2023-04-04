import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as Services;

import 'automated_verification.dart';
import '../main.dart' as Main;

class AddTokenPage extends StatelessWidget {
  final Main.ClaimInfo claim;

  const AddTokenPage({Key? key, required this.claim}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final token = base64Url.encode(claim.pointer.system.key);

    return Scaffold(
      appBar: AppBar(
        title: Main.makeAppBarTitleText('Add Token'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                margin: const EdgeInsets.only(left: 5.0),
                child: const Text(
                  "Token",
                  style: TextStyle(
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              margin: const EdgeInsets.all(5.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Main.tokenColor,
                  foregroundColor: Colors.black,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Text(token,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        "Tap to copy",
                        style: TextStyle(
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
                onPressed: () async {
                  await Services.Clipboard.setData(
                      Services.ClipboardData(text: token));

                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Copied')));
                },
              ),
            ),
            const SizedBox(height: 450),
            Align(
              alignment: AlignmentDirectional.center,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Main.blueButtonColor,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    '     Verify     ',
                    style: TextStyle(
                      fontFamily: 'inter',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AutomatedVerificationPage(
                        claim: claim,
                      );
                    }));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
