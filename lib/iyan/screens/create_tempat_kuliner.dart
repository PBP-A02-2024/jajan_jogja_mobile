import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreateTempatKuliner extends StatefulWidget {
  const CreateTempatKuliner({super.key});

  @override
  State<CreateTempatKuliner> createState() => _CreateTempatKulinerState();
}

class _CreateTempatKulinerState extends State<CreateTempatKuliner> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _fotoLinkController = TextEditingController();
  double _longitudeController = 0.0;
  double _latitudeController = 0.0;
  TimeOfDay _jamBukaController = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _jamTutupController = TimeOfDay(hour: 21, minute: 0);
  double _ratingController = 0.0; // Default rating
  List<int> _variasiController = [];
  List<Map<String, dynamic>> _variasiOptions = [];

  Future<void> _fetchVariasi() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
          'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/adm/json-variasi/');
      if (response != null) {
        setState(() {
          _variasiOptions =
              List<Map<String, dynamic>>.from(response.map((item) {
            return {
              'id': item['pk'],
              'nama': item['fields']['nama'],
            };
          }));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error mengambil variasi: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVariasi();
  }

  Future<void> _createTempatKuliner() async {
    final request = context.read<CookieRequest>();
    try {
      final data = {
        "nama": _namaController.text,
        "description": _descriptionController.text,
        "alamat": _alamatController.text,
        "longitude": _longitudeController,
        "latitude": _latitudeController,
        "jam_buka": _jamBukaController.format(context),
        "jam_tutup": _jamTutupController.format(context),
        "foto_link": _fotoLinkController.text,
        "rating": _ratingController,
        "variasi": _variasiController,
      };

      final response = await request.postJson(
        'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/adm/create-resto-flutter/',
        jsonEncode(data),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tempat kuliner berhasil ditambahkan!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Error: ${response['message'] ?? 'Terjadi kesalahan'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saat menambahkan tempat kuliner: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Tempat Kuliner"),
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
                _buildNumberField(
                  hintText: "Longitude",
                  labelText: "Longitude",
                  onChanged: (value) {
                    _longitudeController = double.tryParse(value!) ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Longitude tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                _buildNumberField(
                  hintText: "Latitude",
                  labelText: "Latitude",
                  onChanged: (value) {
                    _latitudeController = double.tryParse(value!) ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Latitude tidak boleh kosong!";
                    }
                    return null;
                  },
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
                ),
                _buildTextField(
                  hintText: "Foto Link",
                  labelText: "Foto Link",
                  controller: _fotoLinkController,
                ),
                _buildDisabledRatingField(),
                _buildVariasiCheckbox(),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _createTempatKuliner();
                      }
                    },
                    child: const Text("Simpan"),
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

  Widget _buildNumberField({
    required String hintText,
    required String labelText,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildDisabledRatingField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: _ratingController.toString(),
        decoration: const InputDecoration(
          labelText: "Rating (Tidak dapat diubah)",
          border: OutlineInputBorder(),
        ),
        enabled: false,
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

  Future<void> _selectTime(BuildContext context, bool isBuka) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBuka ? _jamBukaController : _jamTutupController,
    );
    if (picked != null) {
      setState(() {
        if (isBuka) {
          _jamBukaController = picked;
        } else {
          _jamTutupController = picked;
        }
      });
    }
  }
}
