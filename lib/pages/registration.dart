import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:archery/data/data.dart';
import 'package:archery/data/di.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late String type = '';
  bool highlightButton = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment(0, 0),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 52, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      hintText: 'Введите имя',
                      prefixIcon: Icon(Icons.person, color: Colors.green),
                      border: OutlineInputBorder(),
                    ),
                    validator: MultiValidator([
                      MinLengthValidator(2, errorText: 'Минимум 2 символа'),
                    ]),
                  ),
                ),
                SizedBox(height: 12),

                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Фамилия',
                      hintText: 'Введите фамилию',
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                      border: OutlineInputBorder(),
                    ),
                    validator: MultiValidator([
                      MinLengthValidator(2, errorText: 'Минимум 2 символа'),
                    ]),
                  ),
                ),
                SizedBox(height: 12),

                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Электронная почта',
                      hintText: 'Введите электронную почту',
                      prefixIcon: Icon(Icons.email, color: Colors.lightBlue),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: MultiValidator([
                      EmailValidator(errorText: 'Введите корректную электронную почту'),
                      MinLengthValidator(1, errorText: 'Введите корректную электронную почту'),
                    ]),
                  ),
                ),
                SizedBox(height: 12),

                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      hintText: 'Придумайте пароль',
                      prefixIcon: Icon(Icons.lock, color: Colors.orange),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                        color: Colors.black38,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: MinLengthValidator(8, errorText: 'Минимум 8 символов'),
                  ),
                ),
                SizedBox(height: 12),

                SizedBox(
                  width: 320,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child:
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              type = 'sportsman';
                            });
                          },
                          child: Text('Спортсмен'),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: type == 'sportsman' ? Color(0xFF95d5b2) : null,
                            foregroundColor: type == 'sportsman' ? Colors.white : Colors.black,
                            side: highlightButton ? BorderSide(color: Colors.red, width: 2) : BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(width: 20),

                      Expanded(child:
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              type = 'coach';
                            });
                          },
                          child: Text('Тренер'),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: type == 'coach' ? Color(0xFF95d5b2) : null,
                            foregroundColor: type == 'coach' ? Colors.white : Colors.black,
                            side: highlightButton ? BorderSide(color: Colors.red, width: 2) : BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(fontSize: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      bool check = _formKey.currentState!.validate();

                      if (type == '') {
                        setState(() => highlightButton = true);
                        Future.delayed(Duration(milliseconds: 500), () {
                          setState(() => highlightButton = false);
                        });
                        return;
                      }

                      if (check) {
                        try {
                          final auth = FirebaseAuth.instance;

                          await auth.createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );

                          // без подтверждения
                          await sl<Data>().firstSaveToken(
                            firstNameController.text,
                            lastNameController.text,
                            emailController.text,
                            type,
                          );

                          FocusScope.of(context).unfocus();
                          await Navigator.pushReplacementNamed(context, '/main_navigation');
                          //

                          // с подтверждением
                          // await auth.currentUser?.sendEmailVerification();
                          // showDialog(
                          //   context: context,
                          //   barrierDismissible: false,
                          //   builder: (_) => AlertDialog(
                          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          //     // title: const Text(
                          //     //   'Письмо отправлено',
                          //     //   style: TextStyle(fontWeight: FontWeight.w600),
                          //     // ),
                          //     content: Text(
                          //       'Письмо с подтверждением отправлено на \n${emailController.text}',
                          //       style: TextStyle(fontSize: 15),
                          //     ),
                          //     actionsPadding: EdgeInsets.only(bottom: 12, right: 12),
                          //     actions: [
                          //       Center(
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.start,
                          //           children: [
                          //             TextButton(
                          //               style: TextButton.styleFrom(
                          //                 foregroundColor: Colors.white,
                          //                 backgroundColor: Color(0xFF95d5b2),
                          //                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          //               ),
                          //               onPressed: () async {
                          //                 final user = auth.currentUser;
                          //                 await user?.reload();
                          //
                          //                 await user?.delete();
                          //                 Navigator.of(context).pop();
                          //               },
                          //               child: Text('Вернуться к регистрации', style: TextStyle(fontSize: 16)),
                          //             ),
                          //             SizedBox(height: 12,),
                          //
                          //             TextButton(
                          //               style: TextButton.styleFrom(
                          //                 foregroundColor: Colors.white,
                          //                 backgroundColor: Color(0xFF95d5b2),
                          //                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          //               ),
                          //               onPressed: () async {
                          //                 final user = auth.currentUser;
                          //                 await user?.reload();
                          //
                          //                 if (user?.emailVerified ?? false) {
                          //                   await sl<Data>().saveToken(
                          //                     firstNameController.text,
                          //                     lastNameController.text,
                          //                     emailController.text,
                          //                     type,
                          //                   );
                          //                   await Navigator.pushNamed(context, '/');
                          //                 }
                          //               },
                          //               child: Text('Я подтвердил(a)', style: TextStyle(fontSize: 16)),
                          //             ),
                          //           ],
                          //         ),
                          //       )
                          //
                          //     ],
                          //   ),
                          // );
                        } catch (e) {
                          String msg = 'Ошибка регистрации';

                          if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
                            msg = 'Эта почта уже зарегистрирована';
                          }

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      }
                    },
                    child: Text('Зарегистрироваться', style: TextStyle(fontSize: 18, color: Colors.white,),),
                  ),
                ),

                SizedBox(height: 0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Уже есть аккаунт?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/enter');
                      },
                      child: Text(
                        'Войти',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
