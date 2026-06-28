import 'package:project_app_uas/db_helper.dart';
import 'package:project_app_uas/main_page.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  // controller
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _konfirmasi_password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 35),
          child: Column(
            children: [
              SizedBox(height: 80),
              Image.asset('images/banner_login.png'),
              SizedBox(height: 10),
              Text(
                isLogin ? 'Login' : 'Daftar',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              // kolom konfirmasi password
              if (isLogin == false) ...[
                SizedBox(height: 15),
                TextField(
                  controller: _konfirmasi_password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  // child: Text(isLogin ? 'Login' : 'Daftar'),
                  child: Text(
                    isLogin ? 'Login' : 'Daftar',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () async {
                    DbHelper _db = DbHelper();
                    if (isLogin) {
                      // logika untuk login
                      bool loginSukses = await _db.checkLogin(
                        _username.text,
                        _password.text,
                      );
                      if (loginSukses) {
                        // masuk ke home
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainPage(),
                          ),
                        );
                      } else {
                        // tampilkan pesan username/password salah menggunakan cnackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Username atau Password salah!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        _password.clear();
                      }
                    } else {
                      // logika registrasi
                      if (_password.text == _konfirmasi_password.text &&
                          _username.text.isNotEmpty) {
                        await _db.register(_username.text, _password.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Registrasi Berhasil! Anda sudah bisa Login',
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // kembali ke mode login
                        setState(() {
                          isLogin = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Registrasi Gagal! Pastikan nama dan password sesuai',
                            ),
                            backgroundColor: Colors.redAccent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? 'Belum punya akun? Daftar'
                      : 'Sudah punya akun? Login',
                  style: TextStyle(color: Color(0xFF233443)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
