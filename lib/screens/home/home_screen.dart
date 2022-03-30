import 'package:capyba_app/blocs/auth_bloc.dart';
import 'package:capyba_app/models/document_model.dart';
import 'package:capyba_app/screens/profile/profile_screen.dart';
import 'package:capyba_app/screens/validate_email/validate_email_screen.dart';
import 'package:capyba_app/theme/colors.dart';
import 'package:capyba_app/theme/icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  User user = AuthBloc().getUser() as User;
  FirebaseFirestore storage = FirebaseFirestore.instance;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Container tileComponent(Map<String, dynamic> data) {
    DocumentModel documentModel = DocumentModel.fromJson(data);
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text('Nota: ' + documentModel.content)),
            const SizedBox(width: 20),
            Text('Data: ' +
                DateFormat("dd-MM-yyyy")
                    .format(documentModel.created_at.toDate())),
          ]),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)),
          tileColor: AppColors.PRIMARY,
          textColor: AppColors.WHITE,
          onTap: () {},
        ));
  }

  StreamBuilder tabComponent(String collection) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: storage.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error = ${snapshot.error}');
          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            return Padding(
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: docs.length,
                    itemBuilder: (_, index) {
                      final data = docs[index].data();
                      return tileComponent(data);
                    }));
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: AppColors.PRIMARY_DARK,
            key: _scaffoldKey,
            endDrawer: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Drawer(
                    child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      title: const Text('Meu perfil'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()),
                        );
                      },
                    ),
                    if (!user.emailVerified)
                      ListTile(
                        title: const Text('Validar email'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ValidateEmailScreen()),
                          );
                        },
                      ),
                  ],
                ))),
            body: Column(children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: AppColors.PRIMARY_DARK,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue[200],
                          backgroundImage: user.photoURL != null
                              ? Image.network(
                                  user.photoURL.toString(),
                                  fit: BoxFit.cover,
                                ).image
                              : Image.asset(
                                  AppIcons.PROFILE,
                                  fit: BoxFit.cover,
                                ).image,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, ${user.displayName}',
                              style: const TextStyle(
                                  fontSize: 25, color: AppColors.WHITE),
                            ),
                            Text(
                              'Verificado: ${user.emailVerified ? 'Sim' : 'Não'}',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.SECONDARY),
                            ),
                          ],
                        )
                      ],
                    ),
                    IconButton(
                        icon: const Icon(
                          Icons.dehaze,
                          size: 45,
                          color: AppColors.WHITE,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        })
                  ],
                ),
              ),
              Container(
                color: AppColors.WHITE,
                child: TabBar(
                  labelColor: AppColors.PRIMARY,
                  controller: _tabController,
                  onTap: (value) {
                    if (value == 1 && !user.emailVerified) {
                      _tabController.index = _tabController.previousIndex;
                    }
                  },
                  tabs: const [
                    Tab(text: "Home"),
                    Tab(text: "Restrito"),
                  ],
                ),
              ),
              Expanded(
                  child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  tabComponent("home"),
                  tabComponent("restricted"),
                ],
              ))
            ])));
  }
}
