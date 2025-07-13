import 'package:flutter/material.dart';
import 'package:archery/data/data.dart';
import 'package:archery/data/di.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

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
  List<String> coaches = [];
  int maxCoachesToSee = 4;
  bool copied = false;

  static const _appBarColor = Color(0xFFFF8C3A);
  static const _cardColor = Color(0xFFFFECB3);
  static const _accentGreen = Color(0xFF95d5b2);

  Future<void> loadData() async {
    final parts = sl<Data>().token.split(':');

    setState(() {
      firstName = parts[0];
      lastName = parts[1];
      email = parts[2];
      type = parts[3];
      coaches = sl<Data>().getCoaches();
    });
  }

  Future<void> logout(BuildContext context) async {
    sl<Data>().logout();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/registration');
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget _buildRow(IconData icon, String text, double ft) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: _appBarColor, size: 22),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: ft, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: AppBar(
            title: Text('Профиль'),
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Color(0xFFf98948),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 18, right: 18, top: max(70 - 10.0 * maxCoachesToSee, 70 - 10.0 * coaches.length)),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: _cardColor,
                  child: Text(
                    firstName.isNotEmpty && lastName.isNotEmpty ? '${lastName[0]}${firstName[0]}' : '',
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
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 28, 12, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow(Icons.person_outline, '$lastName $firstName', 16),
                        SizedBox(height: 16),
                        _buildRow(Icons.email_outlined, email, 16),
                        SizedBox(height: 16),
                        _buildRow(Icons.flag_outlined, type == 'coach' ? 'Тренер' : 'Спортсмен', 16),
                        if (type == 'sportsman') ... [
                          SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.sports, color: _appBarColor, size: 22),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0; i < min(coaches.length, maxCoachesToSee); ++i) ... [
                                    Text('${coaches[i].split(':')[0]} ${coaches[i].split(':')[1]}${i == maxCoachesToSee - 1 && coaches.length > maxCoachesToSee? ' ...' : ''}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  ],
                                  if (coaches.length == 0) ... [
                                    Text('-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  ]
                                ],
                              )
                            ],
                          ),
                        ],
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
                      elevation: 2,
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

          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 18, right: 18),
                child: Text('По вопросам сотрудничества писать на почту:',
                  style: TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20, left: 18, right: 18),
                child: GestureDetector(
                  onTap: () async {
                    Clipboard.setData(ClipboardData(text: 'archery.team131@gmail.com'));
                    setState(() => copied = true);
                    await Future.delayed(Duration(milliseconds: 350));
                    setState(() => copied = false);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: copied ? Colors.lightBlue.shade50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'archery.team131@gmail.com',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),

                ),
                // child: GestureDetector(
                //   onTap: () {
                //     Clipboard.setData(ClipboardData(text: 'archery.team131@gmail.com'));
                //
                //     // у Android часто вылезает системная всплывашка, это надо только для ios
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text(
                //           'Скопировано в буфер обмена',
                //           textAlign: TextAlign.center,
                //           style: TextStyle(color: Colors.white, fontSize: 16),
                //         ),
                //         duration: Duration(milliseconds: 4000),
                //         backgroundColor: Colors.black54,
                //         behavior: SnackBarBehavior.floating,
                //         margin: EdgeInsets.only(bottom: 3, left: 48, right: 48,),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(22),
                //         ),
                //       ),
                //     );
                //
                //   },
                //
                //   child: Text(
                //     'archery.team131@gmail.com',
                //     style: TextStyle(fontSize: 12, color: Colors.blue),
                //   ),
                // )
              )
            ],
          )
        ],
      )
    );
  }
}