import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:file_picker/file_picker.dart' as FilePicker;

import '../main.dart' as Main;
import '../protocol.pb.dart' as Protocol;
import 'backup.dart';
import 'claim.dart';
import 'create_claim.dart';
import 'new_or_import_profile.dart';

class ProfilePage extends StatefulWidget {
  final int identityIndex;

  const ProfilePage({Key? key, required this.identityIndex}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<StatelessWidget> _renderClaims(List<Main.ClaimInfo> claims) {
    List<StatelessWidget> result = [];

    for (var i = 0; i < claims.length; i++) {
      result.add(Main.StandardButtonGeneric(
        actionText: claims[i].claimType,
        actionDescription: claims[i].text,
        left: Container(
          margin: const EdgeInsets.only(top: 5, bottom: 5),
          child: Main.claimTypeToVisual(claims[i].claimType),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ClaimPage(
              identityIndex: widget.identityIndex,
              claimIndex: i,
            );
          }));
        },
        onDelete: () {},
      ));
    }

    return result;
  }

  final TextEditingController usernameController = TextEditingController();
  String newUsername = "";

  Future<void> editUsername(
    BuildContext context,
    Main.PolycentricModel state,
    Main.ProcessSecret identity,
  ) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Edit Username"),
            content: TextField(
              onChanged: (next) {
                setState(() {
                  newUsername = next;
                });
              },
              controller: usernameController,
            ),
            actions: [
              TextButton(
                child: const Text("cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("submit"),
                onPressed: () async {
                  await Main.setUsername(
                      state.db, identity, usernameController.text);

                  await state.mLoadIdentities();

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  final TextEditingController descriptionController = TextEditingController();
  String newDescription = "";

  Future<void> editDescription(
    BuildContext context,
    Main.PolycentricModel state,
    Main.ProcessSecret identity,
  ) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Edit Description"),
            content: TextField(
              onChanged: (next) {
                setState(() {
                  newDescription = next;
                });
              },
              controller: descriptionController,
            ),
            actions: [
              TextButton(
                child: const Text("cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("submit"),
                onPressed: () async {
                  await Main.setDescription(
                      state.db, identity, descriptionController.text);

                  await state.mLoadIdentities();

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final state2 = context.watch<Main.PolycentricModel>();
    final identity2 = state2.identities[widget.identityIndex];

    List<StatelessWidget> listViewChildren = [
      Container(
        margin: const EdgeInsets.only(left: 20),
        child: const Text(
          'Claims',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'inter',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
      ),
    ];

    listViewChildren.addAll(_renderClaims(identity2.claims));

    listViewChildren.addAll([
      Container(
        margin: const EdgeInsets.only(left: 20, top: 20),
        child: const Text(
          'Other',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'inter',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
      ),
      Main.StandardButton(
        actionText: 'Make a claim',
        actionDescription: 'Make a new claim for your profile',
        icon: Icons.person_add,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CreateClaimPage(identityIndex: widget.identityIndex);
          }));
        },
      ),
      Main.StandardButton(
        actionText: 'Vouch for a claim',
        actionDescription: 'Vouch for someone elses claim',
        icon: Icons.video_call,
        onPressed: () async {
          try {
            final String rawScan = await FlutterBarcodeScanner.scanBarcode(
                "#ff6666", 'cancel', false, ScanMode.QR);
            final List<int> buffer = base64.decode(rawScan);
            final Protocol.Pointer pointer =
                Protocol.Pointer.fromBuffer(buffer);

            await Main.makeVouch(state2.db, identity2.processSecret, pointer);
          } catch (err) {
            print(err);
          }
        },
      ),
      Main.StandardButton(
        actionText: 'Change account',
        actionDescription: 'Switch to a different account',
        icon: Icons.switch_account,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const NewOrImportProfilePage();
          }));
        },
      ),
      Main.StandardButton(
        actionText: 'Backup',
        actionDescription: 'Make a backup of your identity',
        icon: Icons.save,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const BackupPage();
          }));
        },
      ),
      Main.StandardButton(
        actionText: 'Delete account',
        actionDescription: 'Permanently account from this device',
        icon: Icons.delete,
        onPressed: () async {
          final public =
              await identity2.processSecret.system.extractPublicKey();

          await Main.deleteIdentity(
              state2.db, public.bytes, identity2.processSecret.process);

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const NewOrImportProfilePage();
          }));

          await state2.mLoadIdentities();
        },
      ),
    ]);

    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          InkWell(
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                foregroundImage:
                    identity2.avatar != null ? identity2.avatar!.image : null,
              ),
            ),
            onTap: () async {
              FilePicker.FilePickerResult? result =
                  await FilePicker.FilePicker.platform.pickFiles(
                type: FilePicker.FileType.custom,
                allowedExtensions: ['png', 'jpg'],
              );

              if (result != null) {
                final bytes =
                    await File(result.files.single.path!).readAsBytes();

                final pointer = await Main.publishBlob(
                  state2.db,
                  identity2.processSecret,
                  "image/jpeg",
                  bytes,
                );

                await Main.setAvatar(
                  state2.db,
                  identity2.processSecret,
                  pointer,
                );

                print("set avatar");
              }
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 30),
              Text(
                identity2.username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w300,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              OutlinedButton(
                child: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  semanticLabel: "edit",
                  color: Colors.white,
                ),
                onPressed: () {
                  editUsername(context, state2, identity2.processSecret);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: const Text(
                "About",
                style: TextStyle(
                  fontFamily: 'inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Main.tokenColor,
                foregroundColor: Colors.black,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(identity2.description,
                        style: const TextStyle(
                          fontFamily: 'inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        )),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 15,
                      semanticLabel: "edit",
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              onPressed: () {
                editDescription(context, state2, identity2.processSecret);
              },
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: listViewChildren,
            ),
          ),
        ],
      ),
    ));
  }
}
