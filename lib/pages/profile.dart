import 'package:flutter/material.dart';
import 'package:archery/data/data.dart';
import 'package:archery/data/di.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String type = '';

  static const _appBarColor = Color(0xFFFF8C3A);
  static const _cardColor = Color(0xFFFFECB3);
  static const _accentGreen = Color(0xFF95d5b2);

  Future<void> loadData() async {
    final token = await sl<Data>().loadToken();
    final parts = token.split(':');
    setState(() {
      firstName = parts[0];
      lastName = parts[1];
      email = parts[2];
      type = parts[3];
    });
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/registration');
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Container( // extra container for custom bottom shadows
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                spreadRadius: 3,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: AppBar(
            title: DropdownButtonHideUnderline(
                child: Text('Профиль')
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Color(0xFFf98948),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView (
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: _cardColor,
                child: Text(
                  firstName.isNotEmpty && lastName.isNotEmpty ? '${firstName[0]}${lastName[0]}' : '',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: _appBarColor,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Card(
                color: _cardColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 28, 12, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow(Icons.person_outline, '$firstName $lastName', 18),
                      SizedBox(height: 16),
                      _buildRow(Icons.email_outlined, email, 16),
                      SizedBox(height: 16),
                      _buildRow(Icons.flag_outlined, type == 'coach' ? 'Тренер' : 'Спортсмен', 18),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 36),
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    logout(context);
                  },
                  icon: Icon(Icons.logout_rounded),
                  label: Text('Выйти'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentGreen,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String text, double ft) {
    return Row(
      children: [
        Icon(icon, color: _appBarColor, size: 22),
        SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: ft, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}