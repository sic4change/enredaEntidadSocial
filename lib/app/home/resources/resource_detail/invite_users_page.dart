
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CreateSolversCommunityPage extends StatefulWidget {
  const CreateSolversCommunityPage({
    Key? key, required this.resource}) : super(key: key);

  final Resource resource;

  @override
  State<CreateSolversCommunityPage> createState() => _CreateSolutionState();
}

class _CreateSolutionState extends State<CreateSolversCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _usersToInviteError = false;
  String? _name, _userId;
  bool isEditing = false;
  TextEditingController _inviteUserController = TextEditingController(text: "");
  List<UserEnreda> _usersToInvite = [];

  @override
  void initState() {
    super.initState();
    // if (widget.solversCommunity != null)
    //   isEditing = true;
    //
    // if (isEditing){
    //   _name = widget.solversCommunity!.name;
    //   _userId = widget.solversCommunity!.userId;
    //   _getSolversFromCommunity();
    // } else {
    //   _name = "";
    //   _userId = "";
    // }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inviteUserController.dispose();
    super.dispose();
  }

  Future<void> _getSolversFromCommunity() async {
    final database = Provider.of<Database>(context, listen: false);

    //final registeredUsers = await database.solverUsersStreamBySolversCommunity(widget.solversCommunity!).first;
    List<User> notRegisteredUsers = [];
    for (var userId in widget.resource.participants!) {
      //if (isEmailValid(userId)) notRegisteredUsers.add(User(email: userId, ecosystemsIdList: [], subEcosystemsIdList: []));
    }

    setState(() {
      //_usersToInvite.addAll(registeredUsers);
      //_usersToInvite.addAll(notRegisteredUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          primary: false,
          child: Padding(
              padding: Responsive.isMobile(context)
                  ? const EdgeInsets.all(0.0)
                  : EdgeInsets.all(20),
              child: _buildForm(context)),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildFormChildren(context),
        ),
      ),
    );
  }

  List<Widget> _buildFormChildren(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    String userStr = StringConst.THE_USER;
    String alreadyAddedStr = StringConst.ALREADY_ADDED;

    return [
      StreamBuilder<UserEnreda>(
          stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              _userId = snapshot.data!.userId;
            }

            return CupertinoScrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                primary: true,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Center(child: CustomTextMedium(
                            text: StringConst.ADD_USER.toUpperCase())
                          ,),
                      ),
                      TextFormField(
                          decoration: customTextFormFieldDialog(context,'${StringConst.RESOURCES} *').copyWith(
                              floatingLabelBehavior: FloatingLabelBehavior.always
                          ),
                          initialValue: _name,
                          validator: (value) => value!.isNotEmpty ? null : StringConst.NAME_ERROR,
                          onSaved: (value) => _name = value,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.text),
                      SizedBox(height: 20 ),
                      TextFormField(
                          decoration: customTextFormFieldDialog(context,StringConst.INVITE_USERS).copyWith(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: StringConst.ENTER_TO_ADD,
                          ),
                          controller: _inviteUserController,
                          onFieldSubmitted: (value) async {
                            // if (!isEmailValid(value)) {
                            //   showAlertDialog(
                            //       context,
                            //       title: StringConst.WRONG_EMAIL,
                            //       content: StringConst.WRONG_EMAIL,
                            //       defaultActionText: StringConst.OK
                            //   );
                            // } else if (_isUserInvited(value)) {
                            //   showAlertDialog(
                            //       context,
                            //       title: StringConst.DUPLICATED_USER,
                            //       content: "$userStr $value $alreadyAddedStr",
                            //       defaultActionText: StringConst.OK
                            //   );
                            // } else {
                            //   bool userAdded = await _addUserToCommunity(value);
                            //   if (userAdded) _inviteUserController.clear();
                            //   setState(() { });
                            // }
                          } ,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.text
                      ),
                      if (_usersToInvite.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _usersToInvite.map((user) => Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: _buildUserRow(
                                user: user,
                                onDelete: () {
                                  setState(() {
                                    _usersToInvite.remove(user);
                                  });
                                }
                            ),
                          )).toList(),
                        ),
                      if(!_usersToInviteError) SizedBox(height: 20,),
                      if (_usersToInviteError)
                        Text(
                          StringConst.USER_TO_INVITE_ERROR,
                          style: textTheme.bodySmall!.copyWith(
                              color: Colors.red
                          ),
                        ),
                      SizedBox(height: 20 * 2),
                      EnredaButton(
                        buttonTitle: StringConst.SAVE,
                        onPressed: _submit,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                    ]),
              ),
            );
          }
      )
    ];
  }

  Widget _buildUserRow({required UserEnreda user, required VoidCallback onDelete}) {
    return Row(
      children: [
        //Avatar(photoUrl: user.profilePicture, radius: 30),
        SizedBox(width: 20,),
        Expanded(
            child: Text(user.userId == null? "${user.email}": "${user.firstName} ${user.lastName}")
        ),
        InkWell(
            onTap: onDelete,
            child: Icon(Icons.delete_outline_rounded, color: AppColors.greyAlt,)
        ),
      ],
    );
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;

    if (_usersToInvite.isEmpty) {
      setState(() {
        _usersToInviteError = true;
      });
      return false;
    } else {
      setState(() {
        _usersToInviteError = false;
      });
    }

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    // if (_validateAndSaveForm()) {
    //
    //   final solversIds = _usersToInvite.map((user) =>
    //   (user.userId != null && user.userId!.isNotEmpty)? user.userId!: user.email!
    //   ).toList();
    //
    //   if (isEditing) {
    //     final solversCommunity = SolversCommunity(
    //       solversCommunityId: widget.solversCommunity!.solversCommunityId,
    //       name: _name!,
    //       userId: _userId,
    //       searchText: _name,
    //       challengesIds: widget.solversCommunity!.challengesIds,
    //       solversIds: solversIds,
    //     );
    //     _editSolversCommunity(solversCommunity);
    //     await showAlertDialog(context, title: "", content: StringConst.EDITED_COMMUNITY, defaultActionText: StringConst.OK);
    //   } else {
    //     final solversCommunity = SolversCommunity(
    //       name: _name!,
    //       userId: _userId,
    //       searchText: _name,
    //       challengesIds: [],
    //       solversIds: solversIds,
    //     );
    //     _addSolversCommunity(solversCommunity);
    //     await showAlertDialog(context, title: "", content: StringConst.CREATED_COMMUNITY, defaultActionText: StringConst.OK);
    //   }
    //   context.pop();
    // }
  }

  // Future<void> _addSolversCommunity(SolversCommunity solversCommunity) async {
  //   final database = Provider.of<Database>(context, listen: false);
  //   await database.addSolversCommunity(solversCommunity);
  // }
  //
  // Future<void> _editSolversCommunity(SolversCommunity solversCommunity) async {
  //   final database = Provider.of<Database>(context, listen: false);
  //   await database.setSolversCommunity(solversCommunity);
  // }
  //
  // bool _isUserInvited(String email) {
  //   if (_usersToInvite.any((u) => u.email == email)) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  /*Future<bool> _addUserToCommunity(String email) async{
    final database = Provider.of<Database>(context, listen: false);
    final user = await database.userStreamByEmail(email).first;
    String userStr = StringConst.THE_USER;
    String nonSolverStr = StringConst.NON_SOLVER_ROLE;
    if (user != null) {
      if (user.role == "Solver") {
        _usersToInvite.add(user);
        return true;
      } else {
        showAlertDialog(
            context,
            title: StringConst.NON_SOLVER_USER,
            content: "$userStr $email $nonSolverStr",
            defaultActionText: StringConst.OK
        );
        return false;
      }
    } else {
      _usersToInvite.add(User(email: email, ecosystemsIdList: [], subEcosystemsIdList: []));
      return true;
    }
  }*/
}
