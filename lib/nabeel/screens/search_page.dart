import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:jajan_jogja_mobile/iyan/models/resto.dart';
import 'package:jajan_jogja_mobile/nabeel/models/variasi.dart';
import 'package:jajan_jogja_mobile/nabeel/widgets/tempatkuliner_card.dart';
import 'package:jajan_jogja_mobile/nabeel/widgets/search_history_dropdown.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:jajan_jogja_mobile/nabeel/models/search.dart';
import 'package:jajan_jogja_mobile/widgets/header_app.dart';
import 'package:jajan_jogja_mobile/widgets/navbar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Search> _searchList = [];
  List<TempatKuliner> _restoList = [];
  List<Variasi> _kategoriList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchNama = '';
  String _kategoriPilih = '';
  TextEditingController _searchController = TextEditingController();

  Future<void> fetchSearch(CookieRequest request) async {
    try {
      final response = await request.get(
          'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/search/show-search-history/');
      List<Search> listSearch = [];
      for (var d in response) {
        if (d != null) {
          listSearch.add(Search.fromJson(d));
        }
      }
      setState(() {
        _searchList = listSearch;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> fetchVariasi(CookieRequest request) async {
    try {
      final response = await request.get(
          'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/search/show-variasi/');
      List<Variasi> listVariasi = [];
      for (var d in response) {
        if (d != null) {
          listVariasi.add(Variasi.fromJson(d));
        }
      }
      setState(() {
        _kategoriList = listVariasi;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> fetchResto(
      CookieRequest request, String nama, String kategori) async {
    try {
      var response;
      if (nama.isEmpty) {
        response = await request.get(
            'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/json-tempat/');
      } else {
        if (kategori.isEmpty) {
          response = await request.get(
              'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/search/show-tempat-kuliner-by-keyword/$nama');
        } else {
          response = await request.get(
              'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/search/show-tempat-kuliner-by-category/$nama-$kategori');
        }
      }
      List<TempatKuliner> listResto = [];
      for (var d in response) {
        if (d != null) {
          listResto.add(TempatKuliner.fromJson(d));
        }
      }
      setState(() {
        _restoList = listResto;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> deleteSearch(CookieRequest request, String id) async {
    try {
      await request.post(
          'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/search/delete/$id',
          {});
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
    fetchSearch(request);
  }

  Future<void> editSearch(
      CookieRequest request, String id, String content) async {
    try {
      await request.post(
          'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/search/edit/$id',
          jsonEncode({'content': content}));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
    fetchSearch(request);
  }

  void _showEditDialog(Search search) {
    final TextEditingController contentController =
        TextEditingController(text: search.fields.content);
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          content: Container(
            height: 250,
            width: 400,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Theme.of(context).colorScheme.secondary, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Search History",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: "Content",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(
                      text: DateFormat('dd/MM/yyyy, HH:mm:ss')
                          .format(search.fields.createdAt)),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Created At",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2),
                    ),
                    filled: true,
                    fillColor: Color(0xb8b6afb2),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFe43d12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          Text("Back", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        editSearch(context.read<CookieRequest>(), search.pk,
                            contentController.text);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFefb11d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          Text("Save", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editSearch(Search search) {
    _showEditDialog(search);
  }

  void _deleteSearch(Search search) {
    final request = context.read<CookieRequest>();
    deleteSearch(request, search.pk);
  }

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    fetchSearch(request);
    fetchResto(request, "", "");
    fetchVariasi(request);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: headerApp(context),
      bottomNavigationBar: navbar(context, "search"),
      body: Stack(
        children: [
          // Top-left decoration
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                // color: Color(0xFFe43d12),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFe43d12),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          // Top-right decoration
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                // color: Color(0xFFe43d12),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFe43d12),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          // Bottom-left decoration
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                // color: Color(0xFFe43d12),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFe43d12),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          // Bottom-right decoration
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                // color: Color(0xFFe43d12),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFe43d12),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Discover Jogja's Best Eats",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Quickly search resto by name, category, or keyword.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 270,
                      child: SearchHistoryDropdown(
                        searchList: _searchList,
                        searchController: _searchController,
                        onSelected: (Search selection) {
                          _searchNama = selection.fields.content;
                        },
                        onEdit: _editSearch,
                        onDelete: (Search search) {
                          _deleteSearch(search);
                          fetchSearch(request);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        _searchNama = _searchController.text;
                        await request.postJson(
                          "https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/search/create-search/",
                          jsonEncode(<String, String>{
                            'content': _searchNama,
                          }),
                        );
                        fetchResto(request, _searchNama, "");
                        fetchSearch(request);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: CircleBorder(),
                        fixedSize: Size(40, 40),
                        padding: EdgeInsets.all(0),
                      ),
                      child: Center(
                        child: HugeIcon(
                            size: 24,
                            icon: HugeIcons.strokeRoundedSearch01,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _searchNama.isEmpty
                  ? SizedBox()
                  : Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Search result for $_searchNama",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 160,
                            height: 40,
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 2),
                            ),
                            child: DropdownButton<String>(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              menuMaxHeight: 300,
                              isExpanded: true,
                              value: _kategoriPilih.isEmpty
                                  ? null
                                  : _kategoriPilih,
                              hint: Text('Select Category'),
                              items: _kategoriList.map((e) {
                                return DropdownMenuItem<String>(
                                  value: e.pk.toString(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                    child: Text(
                                      e.fields.nama,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (kategori) {
                                setState(() {
                                  _kategoriPilih = kategori!;
                                });
                                fetchResto(
                                    request, _searchNama, _kategoriPilih);
                              },
                              dropdownColor: Colors.white.withOpacity(0.9),
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCircleArrowDown01,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 24.0,
                              ),
                              underline: SizedBox(),
                            ),
                          ),
                        ],
                      ),
                    ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? Center(child: Text('Error: $_errorMessage'))
                          : _restoList.isEmpty
                              ? Center(
                                  child: Text(
                                    'No food places found matching your criteria.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 20),
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: 175,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                  ),
                                  itemCount: _restoList.length,
                                  itemBuilder: (context, index) {
                                    final resto = _restoList[index];
                                    return TempatKulinerCard(
                                        tempatKuliner: resto);
                                  },
                                ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
