import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hcareapp/pages/YoneticiPages/bottomAppBarYonetici.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isEditingProfile = false;
  Map<String, dynamic> _editedProfileData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı Profilim'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(_auth.currentUser!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata"));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Veri bulunamadı"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return _isEditingProfile
              ? _buildEditProfileForm(userData)
              : _buildUserProfile(userData);
        },
      ),
      bottomNavigationBar: BottomAppBarYonetici(context),
    );
  }

  Widget _buildUserProfile(Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50.0,
            backgroundImage: NetworkImage(userData['image']),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        _showEditProfileDialog();
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Image.network(
                                userData['image'],
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        );
                      },
                      child: const SizedBox(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            userData['name'],
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            userData['roleName'],
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16.0),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(userData['email']),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(userData['telNo']),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(userData['surname']),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _showEditProfileDialog();
            },
            child: const Text('Profil Düzenle'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm(Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            initialValue: userData['name'],
            onChanged: (value) {
              _editedProfileData['name'] = value;
            },
            decoration: InputDecoration(
              labelText: 'Ad',
            ),
          ),
          TextFormField(
            initialValue: userData['surname'],
            onChanged: (value) {
              _editedProfileData['surname'] = value;
            },
            decoration: InputDecoration(
              labelText: 'Soyad',
            ),
          ),
          TextFormField(
            initialValue: userData['email'],
            onChanged: (value) {
              _editedProfileData['email'] = value;
            },
            decoration: InputDecoration(
              labelText: 'E-posta',
            ),
          ),
          TextFormField(
            initialValue: userData['telNo'],
            onChanged: (value) {
              _editedProfileData['telNo'] = value;
            },
            decoration: InputDecoration(
              labelText: 'Telefon Numarası',
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _saveProfileChanges(_editedProfileData);
            },
            child: Text('Değişiklikleri Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    setState(() {
      _isEditingProfile = true;
    });
  }

  void _saveProfileChanges(Map<String, dynamic> newProfileData) async {
    User? user = _auth.currentUser;
    String userID = user!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userID).update(newProfileData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil başarıyla güncellendi')));
      setState(() {
        _isEditingProfile = false;
      });
    } catch (error) {
      print('Profil güncelleme hatası: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil güncellenirken bir hata oluştu')));
    }
  }
}
