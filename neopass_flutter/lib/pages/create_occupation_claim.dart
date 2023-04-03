import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart' as Main;
import 'profile.dart';

class CreateOccupationClaimPage extends StatefulWidget {
  final int identityIndex;

  const CreateOccupationClaimPage({Key? key, required this.identityIndex})
      : super(key: key);

  @override
  State<CreateOccupationClaimPage> createState() =>
      _CreateOccupationClaimPageState();
}

class _CreateOccupationClaimPageState extends State<CreateOccupationClaimPage> {
  TextEditingController textControllerOrganization = TextEditingController();
  TextEditingController textControllerRole = TextEditingController();
  TextEditingController textControllerLocation = TextEditingController();

  Widget build(BuildContext context) {
    var state = context.watch<Main.PolycentricModel>();
    var identity = state.identities[widget.identityIndex];

    return Scaffold(
      appBar: AppBar(
        title: Main.makeAppBarTitleText('Occupation'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 20),
            ),
            child: Text("Save"),
            onPressed: () async {
              await Main.makeOccupationClaim(
                state.db,
                identity.processSecret,
                textControllerOrganization.text,
                textControllerRole.text,
                textControllerLocation.text,
              );

              await state.mLoadIdentities();

              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProfilePage(
                  identityIndex: widget.identityIndex,
                );
              }));
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            "Organization",
            style: TextStyle(
              fontFamily: 'inter',
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          TextField(
            controller: textControllerOrganization,
            maxLines: null,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: Main.formColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              labelText: "Stanford University, Amazon, Goldman Sachs, ...",
              labelStyle: TextStyle(
                color: Colors.white,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Role",
            style: TextStyle(
              fontFamily: 'inter',
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          TextField(
            controller: textControllerRole,
            maxLines: null,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: Main.formColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              labelText: "Professor of Physics, Engineer, Analyst, ...",
              labelStyle: TextStyle(
                color: Colors.white,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Location",
            style: TextStyle(
              fontFamily: 'inter',
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          TextField(
            controller: textControllerLocation,
            maxLines: null,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: Main.formColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              labelText: "Midwest, Massachusetts, New York City, ...",
              labelStyle: TextStyle(
                color: Colors.white,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
        ],
      ),
    );
  }
}