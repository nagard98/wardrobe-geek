import 'package:esempio/db/profile_db_worker.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:form_field_validator/form_field_validator.dart' as validator;
import 'package:esempio/common/utils.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RegisterState();
  }
}

class RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _controller = TextEditingController();
  late bool isEmailValid;
  late bool isPassValid;
  late bool isPassVisible;
  late bool isNameValid;
  late bool isSurnameValid;

  @override
  void initState() {
    super.initState();
    isSurnameValid = false;
    isPassVisible = false;
    isEmailValid = false;
    isPassValid = false;
    isNameValid = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _save(BuildContext context) async {
    _formKey.currentState!.save();

    bool isRegistered = await personalProfile.register(ProfileDBWorker.profileDBWorker);

    if(isRegistered){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Profilo registrato con successo")));
      Navigator.of(context).pop();
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Errore nella registrazione del profilo")));
    }

  }


  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Registrazione"),
        leading: null,
        actions: [],
      ),
      backgroundColor: const Color(0xFF425C5A),
      frontLayer: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 128.0, 16.0, 16.0),
          child: ListView(
            children: [
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
                  isEmailValid = validation==null;
                  return validation;
                },
                onChanged: (input){
                  setState(() {

                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.check, color: isEmailValid ? Colors.lightGreen : Colors.grey,),
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
                validator: (input){
                  String? validation = passwordValidator.call(input);
                  isPassValid = (validation == null);
                  return validation;
                },
                onChanged: (input){
                  setState(() {

                  });
                },
                cursorColor: const Color(0xFFA4626D),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.check, color: isPassValid ? Colors.lightGreen : Colors.grey,),
                  suffixIcon: IconButton(
                    icon: isPassVisible ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
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
              const SizedBox(height: 20,),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onSaved: (input) {
                  personalProfile.myProfile.name = input!;
                },
                cursorColor: const Color(0xFFA4626D),
                validator: (input) {
                  String? validation = validator.RequiredValidator(errorText: "Questo campo è obbligatorio").call(input);
                  return validation;
                },
                onChanged: (input){
                  setState(() {
                    isNameValid = input.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.check, color: isNameValid ? Colors.lightGreen : Colors.grey,),
                  labelText: 'Nome',
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
              const SizedBox(height: 20,),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onSaved: (input) {
                  personalProfile.myProfile.surname = input!;
                },
                cursorColor: const Color(0xFFA4626D),
                validator: (input) {
                  String? validation = validator.RequiredValidator(errorText: "Questo campo è obbligatorio").call(input);
                  return validation;
                },
                onChanged: (input){
                  setState(() {
                    isSurnameValid = input.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.check, color: isSurnameValid ? Colors.lightGreen : Colors.grey,),
                  labelText: 'Cognome',
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
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                    _save(context);
                  }
                },
                child: const Text("Registrati"),
              ),
              const SizedBox(
                height: 20,
              ),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Non hai un account? "),
                  TextButton(
                      onPressed: () {
                        pushNewScreen(context,
                            screen: Register(), withNavBar: true);
                      },
                      child: Text("Registrati"))
                ],
              )*/
            ],
          ),
        ),
      ),
      backLayer: const SizedBox(),
    );
  }
}
