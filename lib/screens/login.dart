import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:esempio/screens/register.dart';
import 'package:form_field_validator/form_field_validator.dart' as validator;
import 'package:esempio/models/your_account_model.dart';
import 'package:esempio/common/utils.dart';
import 'package:esempio/db/profile_db_worker.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _controller = TextEditingController();
  late bool isPassValid;
  late bool isEmailValid;
  late bool isPassVisible;

  @override
  void initState() {
    isPassValid = false;
    isEmailValid = false;
    isPassVisible = false;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _save(BuildContext context) async {
    _formKey.currentState!.save();

    bool isLoggedIn =
        await personalProfile.login(ProfileDBWorker.profileDBWorker);

    if (isLoggedIn) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Accesso effettuato")));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Errore nell'accesso")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Login"),
        foregroundColor: const Color(0xFFFDCDA2),
        leading: null,
        actions: [],
      ),
      backgroundColor: const Color(0xFF425C5A),
      frontLayer: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          children: [
            const SizedBox(height: 120.0,),
            TextFormField(
              textCapitalization: TextCapitalization.none,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onSaved: (input) {
                personalProfile.myProfile.email = input!;
              },
              cursorColor: const Color(0xFFA4626D),
              validator: (input) {
                String? validation = validator.EmailValidator(
                        errorText: "L'Email inserita non è valida")
                    .call(input);
                isEmailValid = validation == null;
                return validation;
              },
              onChanged: (input) {
                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.check,
                  color: isEmailValid ? Colors.lightGreen : Colors.grey,
                ),
                labelText: 'E-Mail',
                labelStyle: const TextStyle(color: Color(0xFF425C5A)),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF425C5A)),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0)),
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0)),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFFDCDA2), width: 2.0)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              textCapitalization: TextCapitalization.none,
              obscureText: !isPassVisible,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onSaved: (input) {
                personalProfile.myProfile.password = input!;
              },
              validator: (input) {
                String? validation = passwordValidator.call(input);
                isPassValid = (validation == null);
                return validation;
              },
              onChanged: (input) {
                setState(() {});
              },
              cursorColor: const Color(0xFFA4626D),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.check,
                  color: isPassValid ? Colors.lightGreen : Colors.grey,
                ),
                suffixIcon: IconButton(
                  icon: isPassVisible
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.visibility),
                  onPressed: () {
                    setState(() {
                      isPassVisible = !isPassVisible;
                    });
                  },
                ),
                labelText: 'Password',
                labelStyle: const TextStyle(color: Color(0xFF425C5A)),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF425C5A)),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0)),
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0)),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFFDCDA2), width: 2.0)),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFFA4626D))),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                  _save(context);
                }
              },
              child: Text("Login"),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Non hai un account? "),
                TextButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(const Color(0xFFA4626D))),
                    onPressed: () {
                      pushNewScreen(context,
                          screen: Register(), withNavBar: true);
                    },
                    child: Text("Registrati"))
              ],
            )
          ],
        ),
      ),
      backLayer: const SizedBox(),
    );
  }
}
