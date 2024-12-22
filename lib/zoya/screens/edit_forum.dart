import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jajan_jogja_mobile/zoya/screens/landing_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditForum extends StatefulWidget {
  final String forumId;

  EditForum(this.forumId, {super.key}) {
    if (!isValidUuid(forumId)) {
      throw ArgumentError('Invalid UUID: $forumId');
    }
  }

  bool isValidUuid(String id) {
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(id);
  }

  @override
  State<EditForum> createState() => _EditForumState();
}

class _EditForumState extends State<EditForum> {
  final _formKey = GlobalKey<FormState>();

  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOriginalComment();
  }

  Future<void> _fetchOriginalComment() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
          "https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/json-forum/${widget.forumId}/");

      if (response != null && response['comment'] != null) {
        setState(() {
          _commentController.text = response['comment'];
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to load comment: $error"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: const Text(
            'Edit Comment',
            style: TextStyle(
              color: Color(0xFF7C1D05),
              fontSize: 26,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFEBE9E1),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Comment",
                  labelText: "Comment",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _commentController.text = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Comment tidak boleh kosong!";
                  }
                  return null;
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C1D05),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final response = await request.postJson(
                        "https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/edit-flutter/${widget.forumId}/",
                        jsonEncode(<String, String>{
                          'comment': _commentController.text,
                        }),
                      );
                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Forum berhasil diubah!"),
                          ));
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LandingPage()));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content:
                                Text("Terdapat kesalahan, silakan coba lagi."),
                          ));
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Color(0xFFEBE9E1)),
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
