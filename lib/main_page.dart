import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final url = Uri.parse('http://192.168.17.89/belanjain_api/barang.php');

  late Future<List<dynamic>> _futureBarang;

  @override
  void initState() {
    super.initState();
    _futureBarang = getBarang();
  }

  Future<List<dynamic>> getBarang() async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('gagal muat data');
      }
    } catch (e) {
      throw Exception('error koneksi: $e');
    }
  }

  Future<void> postBarang(
    String nama_barang,
    String qty,
    String harga,
    String? catatan,
  ) async {
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama_barang": nama_barang,
          "qty": qty,
          "harga": harga,
          "catatan": catatan,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'sukses') {
          setState(() {
            _futureBarang = getBarang();
          });

          // tampilkan pesan sukses dengan snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data gagal ditambahkan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('gagal menyimpan ke server');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data gagal ditambahkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> hapusBarang(String id) async {
    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['status'] == 'sukses') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _futureBarang = getBarang();
          }); // Segarkan halaman utama
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal: ${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Gagal tersambung ke server');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void tampilkanForm(BuildContext context) {
    final TextEditingController _namaBarang = TextEditingController();
    final TextEditingController _qty = TextEditingController();
    final TextEditingController _harga = TextEditingController();
    final TextEditingController _catatan = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModelState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 15,
                top: 15,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Tambah Daftar Belanja',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _namaBarang,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang',
                        // prefixText: 'Rp. ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _qty,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _harga,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        prefixText: 'Rp. ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _catatan,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tombol Simpan sekarang berada di tengah dan berukuran lebih lebar
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 45,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // validasi agar nominal tidak kosong
                          if (_namaBarang.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Field harus di isi,tidak boleh kosong!',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          String? catatanValue = _catatan.text.trim().isEmpty
                              ? null
                              : _catatan.text;

                          await postBarang(
                            _namaBarang.text,
                            _qty.text,
                            _harga.text,
                            catatanValue,
                          );

                          _namaBarang.clear();
                          _qty.clear();
                          _harga.clear();
                          catatanValue;

                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        // title: Text(
        //   'Belanja in',
        //   style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        // ),
        title: Image.asset(
          'images/belanjain_logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade50,
        foregroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureBarang,
        builder: (context, snapshot) {
          // jika masih login
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: RefreshProgressIndicator(color: Colors.indigo),
            );
          }
          // jika terjadi error, misal server api nya mati
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi Kesalahan: ${snapshot.error}'));
          }
          // jika data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('belum ada catatan transaksi'));
          }
          //jika sukses
          List<dynamic> listData = snapshot.data!;
          return ListView.builder(
            itemCount: listData.length,
            itemBuilder: (context, index) {
              var barang = listData[index];
              // Parsing data ke int untuk perhitungan total belanja
              int qty = int.tryParse(barang['qty'].toString()) ?? 0;
              int harga = int.tryParse(barang['harga'].toString()) ?? 0;
              int total = qty * harga;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: 6,),
                      // nomor, berdasarkan index
                      CircleAvatar(
                        backgroundColor: const Color.fromARGB(
                          255,
                          233,
                          236,
                          255,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${barang['nama_barang']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jumlah: ${barang['qty']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Harga: Rp. ${barang['harga']},-',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Total: Rp. $total,-',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Conditional rendering catatan
                            if (barang['catatan'] != null &&
                                barang['catatan']
                                    .toString()
                                    .trim()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Catatan: ${barang['catatan']}'),
                            ],
                          ],
                        ),
                      ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // IconButton(
                          //   padding: EdgeInsets.zero,
                          //   constraints: const BoxConstraints(),
                          //   icon: const Icon(
                          //     Icons.edit,
                          //     color: Colors.orange,
                          //     size: 24,
                          //   ),
                          //   onPressed: () {
                          //     // edit
                          //   },
                          // ),
                          // const SizedBox(height: 12,),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            onPressed: () async {
                              await hapusBarang(barang['id'].toString());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // menampilkan  form input
          tampilkanForm(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}
