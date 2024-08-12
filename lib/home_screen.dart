import 'dart:developer';
import 'dart:io';

import 'package:belajar_sqlite/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  File? image;

  void getUsers() async {
    isLoading = true;
    users = await DatabaseHelper.get();
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Belajar SQLite',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createOrUpdate(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(
                  child: Text('Tida ada data'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 60),
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 16),
                      leading: users[index]['image'] == null
                          ? const Icon(Icons.image)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                File(
                                  users[index]['image'],
                                ),
                              ),
                            ),
                      title: Text(users[index]['name']),
                      subtitle: Text(users[index]['email']),
                      trailing: SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                nameController.text = users[index]['name'];
                                emailController.text = users[index]['email'];
                                createOrUpdate(context, id: users[index]['id']);
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () async {
                                await DatabaseHelper.delete(users[index]['id']);
                                getUsers();
                              },
                              child: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: users.length,
                ),
    );
  }

  Future<dynamic> createOrUpdate(BuildContext context, {int? id}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id != null ? 'Edit Data' : 'Tambah Data'),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    label: Text('Nama'),
                    hintText: 'Masukkan nama',
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    label: Text('Email'),
                    hintText: 'Masukkan email',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    XFile? result = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    image = File(result!.path);
                    log(image!.path);
                    setState(() {});
                  },
                  child: const Text('Pilih Gambar'),
                ),
                image != null ? Image.file(image!) : const SizedBox(),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (id != null) {
                  await DatabaseHelper.update(
                    id,
                    nameController.text,
                    emailController.text,
                  );
                } else {
                  await DatabaseHelper.create(
                    nameController.text,
                    emailController.text,
                    image!.path,
                  );
                }
                getUsers();
                Navigator.pop(context);
                nameController.clear();
                emailController.clear();
                image = null;
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
