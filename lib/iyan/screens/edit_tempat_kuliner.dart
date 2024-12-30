import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditTempatKuliner extends StatefulWidget {
  final String id;
  const EditTempatKuliner({super.key, required this.id});

  @override
  State<EditTempatKuliner> createState() => _EditTempatKulinerState();
}

class _EditTempatKulinerState extends State<EditTempatKuliner> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _fotoLinkController = TextEditingController();
  final TextEditingController _longitudeTextController =
      TextEditingController();
  final TextEditingController _latitudeTextController = TextEditingController();

  double _longitudeController = 0.0;
  double _latitudeController = 0.0;
  double _rating = 0.0; // Nilai awal untuk rating
  TimeOfDay _jamBukaController = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _jamTutupController = TimeOfDay(hour: 21, minute: 0);
  List<int> _variasiController = [];
  List<Map<String, dynamic>> _variasiOptions = [];

  Future<void> _getTempatKuliner() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/adm/get-resto-detail/${widget.id}/',
      );

      if (response['status'] == 'success') {
        setState(() {
          _namaController.text = response['data']['nama'];
          _descriptionController.text = response['data']['description'];
          _alamatController.text = response['data']['alamat'];
          _longitudeTextController.text =
              response['data']['longitude'].toString();
          _latitudeTextController.text =
              response['data']['latitude'].toString();
          _longitudeController = double.parse(response['data']['longitude']);
          _latitudeController = double.parse(response['data']['latitude']);
          _fotoLinkController.text = response['data']['foto_link'];
          _rating = double.parse(
              response['data']['rating'].toString()); // Set nilai awal rating
          _jamBukaController = TimeOfDay(
            hour: int.parse(response['data']['jamBuka'].split(':')[0]),
            minute: int.parse(response['data']['jamBuka'].split(':')[1]),
          );
          _jamTutupController = TimeOfDay(
            hour: int.parse(response['data']['jamTutup'].split(':')[0]),
            minute: int.parse(response['data']['jamTutup'].split(':')[1]),
          );
          _variasiController = List<int>.from(
            response['data']['variasi'].map((v) => v['id']),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error mengambil data: $e")),
      );
    }
  }

  Future<void> _fetchVariasi() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
          'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/adm/json-variasi/');
      if (response != null) {
        setState(() {
          _variasiOptions =
              List<Map<String, dynamic>>.from(response.map((item) {
            return {'id': item['pk'], 'nama': item['fields']['nama']};
          }));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error mengambil variasi: $e")),
      );
    }
  }

  Future<void> _updateTempatKuliner() async {
    final request = context.read<CookieRequest>();
    try {
      final data = {
        "nama": _namaController.text,
        "description": _descriptionController.text,
        "alamat": _alamatController.text,
        "longitude": _longitudeController,
        "latitude": _latitudeController,
        "jamBuka": _jamBukaController.format(context),
        "jamTutup": _jamTutupController.format(context),
        "foto_link": _fotoLinkController.text,
        "rating": _rating, // Gunakan nilai rating awal
        "variasi": _variasiController,
      };

      final response = await request.postJson(
        'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/adm/edit-resto-flutter/${widget.id}/',
        jsonEncode(data),
      );

      // final response = await request.postJson(
      //   'http://127.0.0.1:8000/adm/edit-resto-flutter/${widget.id}/',
      //   jsonEncode(data),
      // );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tempat kuliner berhasil diperbarui!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  // Text("Error: ${response['message'] ?? 'Terjadi kesalahan'}")),
                  Text("Error: $response")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saat memperbarui tempat kuliner: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getTempatKuliner();
    _fetchVariasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Tempat Kuliner"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(
                  hintText: "Nama Tempat Kuliner",
                  labelText: "Nama Tempat Kuliner",
                  controller: _namaController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  hintText: "Deskripsi",
                  labelText: "Deskripsi Tempat Kuliner",
                  controller: _descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Deskripsi tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  hintText: "Alamat",
                  labelText: "Alamat",
                  controller: _alamatController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Alamat tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  hintText: "Longitude",
                  labelText: "Longitude",
                  controller: _longitudeTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Longitude tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  hintText: "Latitude",
                  labelText: "Latitude",
                  controller: _latitudeTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Latitude tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  hintText: "Foto Link",
                  labelText: "Foto Link",
                  controller: _fotoLinkController,
                ),
                _buildTimePickerField(
                  hintText: "Jam Buka",
                  labelText: "Jam Buka",
                  time: _jamBukaController,
                  onTap: () => _selectTime(context, true),
                ),
                _buildTimePickerField(
                  hintText: "Jam Tutup",
                  labelText: "Jam Tutup",
                  time: _jamTutupController,
                  onTap: () => _selectTime(context, false),
                ), // Menampilkan rating
                _buildVariasiCheckbox(),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateTempatKuliner();
                      }
                    },
                    child: const Text("Update"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required String labelText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildTimePickerField({
    required String hintText,
    required String labelText,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hintText,
              labelText: labelText,
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: time.format(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildVariasiCheckbox() {
    if (_variasiOptions.isEmpty) {
      return const Text("Tidak ada variasi yang tersedia.");
    }
    return Column(
      children: _variasiOptions.map((variasi) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          child: CheckboxListTile(
            title: Text(variasi['nama']),
            value: _variasiController.contains(variasi['id']),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _variasiController.add(variasi['id']);
                } else {
                  _variasiController.remove(variasi['id']);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _jamBukaController : _jamTutupController,
    );
    if (pickedTime != null) {
      setState(() {
        if (isOpenTime) {
          _jamBukaController = pickedTime;
        } else {
          _jamTutupController = pickedTime;
        }
      });
    }
  }
}