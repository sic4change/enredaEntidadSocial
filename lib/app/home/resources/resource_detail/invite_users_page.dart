
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/user_avatar.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/functions.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class InviteUsersToResourcePage extends StatefulWidget {
  const InviteUsersToResourcePage({
    Key? key, required this.resource}) : super(key: key);

  final Resource resource;

  @override
  State<InviteUsersToResourcePage> createState() => _InviteUsersToResourcePageState();
}

class _InviteUsersToResourcePageState extends State<InviteUsersToResourcePage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool _usersToInviteError = false;
  bool isLoading = false;
  TextEditingController _inviteUserController = TextEditingController(text: "");
  List<UserEnreda> _usersToInvite = [];

  @override
  void initState() {
    super.initState();
    _getParticipants();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inviteUserController.dispose();
    super.dispose();
  }

  Future<void> _getParticipants() async {
    final database = Provider.of<Database>(context, listen: false);
    final participantsUsers = await database.participantsByResourceStream(widget.resource.resourceId!).first;
    List<UserEnreda> notParticipantsUsers = [];
    for (var userId in widget.resource.participants!) {
      if (isEmailValid(userId)) notParticipantsUsers.add(UserEnreda(email: userId, resources: []));
    }

    setState(() {
      _usersToInvite.addAll(participantsUsers);
      _usersToInvite.addAll(notParticipantsUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
          padding: Responsive.isMobile(context)
              ? const EdgeInsets.all(0.0)
              : EdgeInsets.all(20),
          child: _buildForm(context)),
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
    TextTheme textTheme = Theme.of(context).textTheme;
    String userStr = StringConst.THE_USER;
    String alreadyAddedStr = StringConst.ALREADY_ADDED;

    return [
      CupertinoScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
        controller: _scrollController,
        primary: false,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    CustomTextMediumBold(text: StringConst.INVITE_TO_RESOURCE.toUpperCase()),
                    const SpaceH20(),
                    CustomTextMedium(text: widget.resource.title)
                  ],
                ),
              ),
              SizedBox(height: 20 ),
              TextFormField(
                  decoration: customTextFormFieldDialog(context, StringConst.VALID_EMAIL).copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: AppColors.greyTxtAlt,
                        fontWeight: FontWeight.w400,
                      )
                  ),
                  controller: _inviteUserController,
                  onFieldSubmitted: (value) async {
                    if (!isEmailValid(value)) {
                      showAlertDialog(
                          context,
                          title: StringConst.WRONG_EMAIL,
                          content: StringConst.WRONG_EMAIL,
                          defaultActionText: StringConst.OK
                      );
                    } else if (_isUserInvited(value)) {
                      showAlertDialog(
                          context,
                          title: StringConst.DUPLICATED_USER,
                          content: "$userStr $value $alreadyAddedStr",
                          defaultActionText: StringConst.OK
                      );
                    } else {
                      bool userAdded = await _addUserToInvitation(value);
                      if (userAdded) _inviteUserController.clear();
                      setState(() { });
                    }
                  } ,
                  textCapitalization: TextCapitalization.sentences,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w600,
                  ),
                  keyboardType: TextInputType.text
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: CustomText(title: StringConst.ENTER_TO_ADD),
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
              isLoading == true ? Center(child: CircularProgressIndicator()) : EnredaButton(
                buttonTitle: StringConst.INVITE_THIS_RESOURCE,
                onPressed: _submit,
              ),
              SizedBox(
                height: 8.0,
              ),
            ]),
      ),
    )
    ];
  }

  Widget _buildUserRow({required UserEnreda user, required VoidCallback onDelete}) {
    return Row(
      children: [
        userAvatar(context, user.photo ?? ''),
        SizedBox(width: 20,),
        Expanded(
            child: Text(user.userId == null ? "${user.email}" : "${user.firstName} ${user.lastName}")
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
    if(_validateAndSaveForm() == false) {
      await showAlertDialog(context,
          title: StringConst.INVITE_ERROR,
          content: StringConst.INVITE_ERROR, defaultActionText: StringConst.CLOSE);
    }
    if (_validateAndSaveForm()) {
      final usersEmailList = _usersToInvite.map((user) => user.email).toList();
      setState(() => isLoading = true);
      await _sendInvitations(widget.resource, usersEmailList);
      setState(() => isLoading = false);
      await showAlertDialog(context,
          title: StringConst.INVITE_SUCCESS,
          content: StringConst.INVITE_SUCCESS_DESCRIPTION,
          defaultActionText: StringConst.CLOSE);
    }
  }

  Future<void> _sendInvitations(Resource resource, List<String> usersEmailList) async {
    final database = Provider.of<Database>(context, listen: false);
    await database.setResource(resource.copyWith(
      invitationsList: usersEmailList,
    ));
  }

  bool _isUserInvited(String email) {
    if (_usersToInvite.any((u) => u.email == email)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _addUserToInvitation(String email) async{
    final database = Provider.of<Database>(context, listen: false);
    final user = await database.userStreamByEmail(email).first;
    String userStr = StringConst.THE_USER;
    String nonSolverStr = StringConst.NO_YOUNG_ROLE;
    if (user != null) {
      if (user.role == "Desempleado") {
        _usersToInvite.add(user);
        return true;
      } else {
        showAlertDialog(
            context,
            title: StringConst.NO_YOUNG_ROLE,
            content: "$userStr $email $nonSolverStr",
            defaultActionText: StringConst.OK
        );
        return false;
      }
    } else {
      _usersToInvite.add(UserEnreda(email: email, resources: []));
      return true;
    }
  }
}