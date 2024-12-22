import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:jajan_jogja_mobile/iyan/models/resto.dart';
import 'package:jajan_jogja_mobile/iyan/screens/create_tempat_kuliner.dart';
import 'package:jajan_jogja_mobile/iyan/widgets/resto_card.dart';
import 'package:jajan_jogja_mobile/widgets/header_app.dart';
import 'package:jajan_jogja_mobile/zoya/models/community_forum_entry.dart';
import 'package:jajan_jogja_mobile/zoya/screens/edit_forum.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../widgets/navbar.dart';

void main() {
  runApp(MaterialApp(
    home: LandingPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final request = context.read<CookieRequest>();
    final adminStatus = await fetchUserIsAdmin(request);
    setState(() {
      _isAdmin = adminStatus;
    });
  }

  Future<List<TempatKuliner>> fetchTempatKuliner(CookieRequest request) async {
    final response = await request
        .get('https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/json-tempat/');

    var data = response;

    List<TempatKuliner> listTempatKuliner = [];
    for (var d in data) {
      if (d != null) {
        listTempatKuliner.add(TempatKuliner.fromJson(d));
      }
    }
    return listTempatKuliner;
  }

  Future<List<TempatKuliner>> fetchTop5TempatKuliner(
      CookieRequest request) async {
    final response = await request
        .get('https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/json-tempat/');

    var data = response;

    List<TempatKuliner> listTempatKuliner = [];
    int x = 0;
    for (var d in data) {
      if (d != null) {
        if (x == 10) {
          break;
        }
        listTempatKuliner.add(TempatKuliner.fromJson(d));
      }
    }
    return listTempatKuliner;
  }

  Future<String> fetchUsername(int userId, CookieRequest request) async {
    final response = await request.get(
        'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/json-user/$userId/');

    if (response != null) {
      var data = response;

      String username = data['username'] ?? 'Anonymous';

      return username;
    } else {
      throw Exception('Failed to load username');
    }
  }

  Future<bool> fetchUserIsAdmin(CookieRequest request) async {
    final response = await request.get(
        'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/json-current-user/');

    if (response != null) {
      var data = response;

      bool isAdmin = data['is_admin'];

      return isAdmin;
    } else {
      throw Exception('Failed to check if current user is admin');
    }
  }

  Future<Map<String, dynamic>> fetchCurrentUser(CookieRequest request) async {
    final response = await request.get(
        'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/json-current-user/');

    if (response != null) {
      return response;
    } else {
      throw Exception('Failed to fetch current user');
    }
  }

  Future<List<CommunityForumEntry>> fetchCommunityForum(
      CookieRequest request) async {
    final response = await request
        .get('https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/json-forum/');

    var data = response;

    List<CommunityForumEntry> listCommunityForum = [];
    for (var d in data) {
      if (d != null) {
        listCommunityForum.add(CommunityForumEntry.fromJson(d));
      }
    }
    return listCommunityForum;
  }

  Future<void> postForumEntry(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      final response = await request.postJson(
        'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/create-flutter/',
        jsonEncode({'comment': _commentController.text}),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Forum posted successfully')),
        );
        setState(() {
          _commentController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: headerApp(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder<List<TempatKuliner>>(
                future: fetchTop5TempatKuliner(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No restaurant available'));
                  } else {
                    return CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                      ),
                      items: snapshot.data!.map((image) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                image.fields.fotoLink,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "Looking for places to eat in Jogja?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C1D05),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<TempatKuliner>>(
                future: fetchTempatKuliner(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No restaurant available'));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CardTempat(
                              entry,
                              isAdmin: _isAdmin,
                              request: request,
                              onDelete: () => setState(
                                  () {}), // Callback untuk refresh data
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "Community Forum",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C1D05),
                ),
              ),
              const SizedBox(height: 12),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF7C1D05), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFC98809), width: 2),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a comment';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => postForumEntry(request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC98809),
                            ),
                            child: const Text(
                              'Post',
                              style: TextStyle(
                                color: Color(0xFFEBE9E1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
              const SizedBox(height: 24),
              FutureBuilder<List<CommunityForumEntry>>(
                future: fetchCommunityForum(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No forum data available'));
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: snapshot.data!.map((entry) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<String>(
                                    future: fetchUsername(
                                        entry.fields.user, request),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (userSnapshot.hasError) {
                                        return Text(
                                            'Error: ${userSnapshot.error}');
                                      } else {
                                        return Text(
                                          "${userSnapshot.data}",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFC98809),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.fields.comment,
                                    style: const TextStyle(
                                        fontSize: 14, color: Color(0xFF0F0401)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Posted on ${DateFormat('yyyy-MM-dd').format(entry.fields.time)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: fetchCurrentUser(request),
                                    builder: (context, currentUserSnapshot) {
                                      if (currentUserSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox.shrink();
                                      } else if (currentUserSnapshot.hasError) {
                                        return const SizedBox.shrink();
                                      } else {
                                        final currentUser =
                                            currentUserSnapshot.data?['id'];
                                        if (currentUser == entry.fields.user) {
                                          return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditForum(
                                                                  entry.pk)),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFC98809),
                                                  ),
                                                  child: const Text('Edit',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                const SizedBox(width: 12),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final response =
                                                        await request.get(
                                                            "https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/delete-flutter/${entry.pk}/");

                                                    if (context.mounted) {
                                                      if (response['status'] ==
                                                          'success') {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              "Forum berhasil dihapus!"),
                                                        ));
                                                        setState(() {});
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              "Terdapat kesalahan, silakan coba lagi."),
                                                        ));
                                                      }
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFE43D12),
                                                  ),
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                )
                                              ]);
                                        }
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),
                                  const Divider(color: Color(0xFFC98809)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: navbar(context, "home"),
      // Menambahkan tombol Add di pojok kanan bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _isAdmin
          ? Padding(
              padding: const EdgeInsets.only(
                  bottom: 70), // Menyesuaikan jarak dari navbar
              child: FloatingActionButton(
                onPressed: () {
                  // Navigasi ke halaman CreateTempatKuliner
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTempatKuliner(),
                    ),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 237, 178, 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 151, 103, 0),
                      size: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Restoran',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 151, 103, 0),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(), // Tidak menampilkan tombol jika bukan admin
    );
  }
}
