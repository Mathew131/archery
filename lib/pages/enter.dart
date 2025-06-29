import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:archery/data/data.dart';
import 'package:archery/data/di.dart';

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
  late String type = '';

  Future<void> load_data() async {
    final loggedIn = await sl<Data>().isLoggedIn();

    if (loggedIn) {
      String token = await sl<Data>().loadToken();
      firstNameController.text = token.split(':')[0];
      lastNameController.text = token.split(':')[1];
      emailController.text = token.split(':')[2];
      type = token.split(':')[3];
    }
  }

  @override
  void initState() {
    load_data();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Align(
        alignment: Alignment(0, -0.3),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
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
                    ]),
                  ),
                ),
                SizedBox(height: 24),

                SizedBox(
                  width: 320,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child:
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              type = 'Спортсмен';
                            });
                          },
                          child: Text('Спортсмен'),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: type == 'Спортсмен' ? Color(0xFF95d5b2) : null,
                            foregroundColor: type == 'Спортсмен' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(width: 24),

                      Expanded(child:
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              type = 'Тренер';
                            });
                          },
                          child: Text('Тренер'),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: type == 'Тренер' ? Color(0xFF95d5b2) : null,
                            foregroundColor: type == 'Тренер' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),
                SizedBox(
                  width: 320,
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
                      if (_formKey.currentState!.validate() && type != '') {
                        await sl<Data>().saveToken(firstNameController.text, lastNameController.text, emailController.text, type);
                        await Navigator.pushNamed(context, '/home');
                      }
                    },
                    child: Text('Вход'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
