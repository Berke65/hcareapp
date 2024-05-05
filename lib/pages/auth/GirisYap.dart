import 'package:firebase_auth/firebase_auth.dart';
import 'package:hcareapp/main.dart';
import 'package:flutter/material.dart';
import 'package:hcareapp/pages/SickPages/SickInformation.dart';
import 'package:hcareapp/pages/YoneticiPages/AnaSayfaYonetici.dart';
import 'package:hcareapp/pages/NursePages/NursePageHome.dart';
import 'package:hcareapp/pages/auth/passwd.dart';
import 'package:hcareapp/pages/SickPages/SickAnasayfa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const GirisYap());
}

class GirisYap extends StatefulWidget {
  const GirisYap({super.key});

  @override
  State<GirisYap> createState() => _GirisYapState();
}

class _GirisYapState extends State<GirisYap> {
  late String email, passwd;
  final formKey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;

  TextEditingController forgotPasswdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/bakalım1.png'), // Arka plan deseni
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // SingleChildScrollView üzerine diğer widget'lar eklenir
            SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child:
                                Image.asset('images/gero1.jpg'), // Logo resmi
                          ),
                          const Row(
                            children: [
                              SizedBox(
                                width: 100,
                              ),
                              Icon(Icons.lock_person),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Giriş Ekranı',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          buildEmail(),
                          customSizedBox(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 22.0),
                            child: passwdTxtField(),
                          ),
                          customSizedBox(),
                          customSizedBox(),
                          CustomButton(
                            icon: Icons.admin_panel_settings_outlined,
                            text: 'Giriş Yap',
                            onPressed: signIn,
                          ),
                          customSizedBox(),
                          CustomButton(
                            icon: Icons.lock_outlined,
                            text: 'Şifremi Unuttum',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Passwd(),
                                ),
                              );
                            },
                          ),
                          customSizedBox(),
                          CustomButton(
                            icon: Icons.home_outlined,
                            text: 'Ana Ekrana Dön',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Main(),
                                ),
                              );
                            },
                          ),
                          customSizedBox(),
                          //Şimdilik sayfayı görmek için açtım silersin canım
                          CustomButton(
                              icon: Icons.healing_outlined,
                              text: 'Hemşire Sayfasına git',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NursePageHome(),
                                  ),
                                );
                              }),
                          customSizedBox(),

                          CustomButton(
                            icon: Icons.sick,
                            text: 'Hasta Sayfasına Giriş',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SickAnasayfa(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildEmail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: emailTextField(),
    );
  }

  TextFormField emailTextField() {
    return TextFormField(
      decoration: textfielddec('E Mail', 'E-Mail'),
      controller: forgotPasswdController,
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
      },
      onSaved: (value) {
        email = value!;
      },
    );
  }

  TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  TextFormField passwdTxtField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Şifre',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey, // Görme butonunun rengi
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bilgileri Eksiksiz Doldurunuz';
        }
      },
      onSaved: (value) {
        passwd = value!;
      },
    );
  }

  void forgotPasswd() async {
    try {
      await firebaseAuth.sendPasswordResetEmail(
          email: forgotPasswdController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text(
                  'Şifre Yenileme linki gönderildi. Lütfen Email Gelen Kutunuzu Kontrol Ediniz'),
            );
          });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Lütfen email kısmını bos bırakmayınız'),
            );
          });
    }
  }

  Future<String?> signInHataYakalama(String email, String password) async {
    String? res;
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      res = "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email": // calısıyor
          res = "Lütfen dogru email biciminde girin";
          break;
        case "invalid-credential":
          res = "Kullanıcı adı veya şifre hatalı";
          break;
        case "invalid-credential":
          res = "Kullanıcı adı veya şifre hatalı";
          break;
        case "user-disabled": // calısıyor
          res = "Kullanici Pasif";
          break;
        default:
          res = 'Failed with error code: ${e.code}';
          break;
      }
    }
    return res;
  }

  void signIn() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final result = await signInHataYakalama(email, passwd);
      if (result == 'success') {
        QuerySnapshot<Map<String, dynamic>> userQuery = await FirebaseFirestore
            .instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        QuerySnapshot<Map<String, dynamic>> sickQuery =
            await FirebaseFirestore.instance.collection('hastaBilgileri').get();

        // Eğer kullanıcı bulunduysa ve sadece bir tane varsa
        if (userQuery.docs.isNotEmpty && userQuery.docs.length == 1) {
          String roleName = userQuery.docs.first.data()['roleName'];

          var hastaMail = sickQuery.docs.first.data()['hastaMail'];

          if (roleName == "Yönetim") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AnaSayfaYonetici()));
          } else if (roleName == "Hemşire") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => NursePageHome()));
          } else if (roleName == "Hasta") {
            if (hastaMail != email) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  'Bilgilerinizi Eksiksiz Doldurunuz! (GEROPİTAL EVDE SAĞLIK HİZMETLERİ)',
                ),
              ));
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SickInformation()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  'Aşama Tamamlandı Anasayfaya yönlendiriliyorsunuz (GEROPİTAL EVDE SAĞLIK HİZMETLERİ)',
                ),
              ));
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SickAnasayfa()));
            }
          }
        } else {
          // Kullanıcı bulunamadı veya birden fazla kullanıcı varsa null döndür
          return null;
        }

        //Navigator.pushReplacement(
        //   context, MaterialPageRoute(builder: (context) => const AnaSayfaYonetici()));
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Hata'),
                content: Text(result!),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Geri dön'))
                ],
              );
            });
      }
    }
  }
}

//textfieldların decoration;
InputDecoration textfielddec(String hintText, String labelText) {
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
    // Label text'i burada ayarlayın
    hintStyle: const TextStyle(
      color: Colors.black45,
      fontSize: 18,
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey,
      ),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black,
      ),
    ),
  );
}

Widget customSizedBox() => const SizedBox(
      height: 17,
    );

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 227,
      height: 45,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 25,
          color: Colors.black,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Arial',
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
