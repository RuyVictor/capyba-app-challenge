import 'dart:io';

import 'package:capyba_app/blocs/auth_bloc.dart';
import 'package:capyba_app/screens/change_password/change_password_screen.dart';
import 'package:capyba_app/screens/home/home_screen.dart';
import 'package:capyba_app/screens/login/login_screen.dart';
import 'package:capyba_app/theme/colors.dart';
import 'package:capyba_app/theme/icons.dart';
import 'package:capyba_app/utils/auth_validation.dart';
import 'package:capyba_app/widgets/button.dart';
import 'package:capyba_app/widgets/default_input.dart';
import 'package:capyba_app/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User user = AuthBloc().getUser() as User;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  bool _disableUpdateButton = false;
  bool _disableBackButton = false;
  final Toast toast = Toast();
  final AuthBloc authBloc = AuthBloc();
  final AuthValidation authValidation = AuthValidation();

  @override
  void initState() {
    super.initState();
    _nameController.text = user.displayName!;
    _emailController.text = user.email!;
    compareInputs();
  }

  void compareInputs() {
    setState(() => _disableUpdateButton = true);
    if (_profileImage != null) {
      setState(() => _disableUpdateButton = false);
      return;
    }
    if (user.displayName != _nameController.text) {
      setState(() => _disableUpdateButton = false);
      return;
    }
    if (user.email != _emailController.text) {
      setState(() => _disableUpdateButton = false);
      return;
    }
  }

  Future<void> onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await authBloc.changeProfileData(
            _nameController.text, _emailController.text, _profileImage);
        toast.showSucess(context, 'Usuário atualizado com sucesso!');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          toast.showWarning(context, 'O email digitado é inválido');
        } else if (e.code == 'email-already-in-use') {
          toast.showWarning(
              context, 'Este email já está sendo usado por outro usuário!');
        } else {
          toast.showWarning(context, 'Erro ao atualizar os dados!');
        }
      }
    }
  }

  Future<void> pickImage() async {
    _profileImage = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.PRIMARY_DARK,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Perfil',
              style: TextStyle(fontSize: 30, color: AppColors.WHITE),
            ),
            centerTitle: true,
            leading: const BackButton()),
        body: Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 20,
                  children: <Widget>[
                    Material(
                        elevation: 10,
                        shape: const CircleBorder(),
                        child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue[200],
                            backgroundImage: _profileImage != null
                                ? Image.file(
                                    File(_profileImage!.path),
                                    fit: BoxFit.cover,
                                  ).image
                                : user.photoURL != null
                                    ? Image.network(
                                        user.photoURL!,
                                        fit: BoxFit.cover,
                                      ).image
                                    : Image.asset(
                                        AppIcons.PROFILE,
                                        fit: BoxFit.cover,
                                      ).image,
                            child: Material(
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await pickImage();
                                  compareInputs();
                                },
                              ),
                            ))),
                    DefaultInput(
                      controller: _nameController,
                      label: 'Nome',
                      validator: authValidation.validateName,
                      onChanged: (value) => {compareInputs()},
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    DefaultInput(
                      controller: _emailController,
                      label: 'Email',
                      validator: authValidation.validateEmail,
                      onChanged: (value) => {compareInputs()},
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                    InkWell(
                        onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChangePasswordScreen()),
                              )
                            },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: const Text(
                            'Mudar senha',
                            style: TextStyle(color: AppColors.WHITE),
                          ),
                        )),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Expanded(
                        child: Button(
                            text: 'Atualizar dados',
                            disabled: _disableUpdateButton,
                            onPressed: () async {
                              setState(() {
                                _disableUpdateButton = true;
                                _disableBackButton = true;
                              });
                              await onSubmit(context);
                              setState(() {
                                _disableUpdateButton = false;
                                _disableBackButton = false;
                              });
                            }),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Button(
                          text: 'Voltar',
                          disabled: _disableBackButton,
                          onPressed: () => Navigator.pop(context),
                        ),
                      )
                    ]),
                    InkWell(
                        onTap: () => {
                              authBloc.signOut(),
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                  (route) => false)
                            },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: const Text(
                            'Deslogar da plataforma',
                            style: TextStyle(color: AppColors.SECONDARY),
                          ),
                        )),
                  ],
                ),
              )),
        ));
  }
}
