// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../constants.dart';

// ignore: must_be_immutable
class SignUpForm extends StatelessWidget {
  SignUpForm({
    super.key,
    required this.onEmailSaved,
    required this.onPasswordSaved,
    required this.formKey,
    required this.onNameSaved,
    required this.onPhoneSaved,
    required this.onConfirmSaved,
    required this.onAgentCodeSaved,
  });
  final void Function(String?) onEmailSaved;
  final void Function(String?) onPasswordSaved;
  final void Function(String?) onNameSaved;
  final void Function(String?) onPhoneSaved;
  final void Function(String?) onConfirmSaved;
  final void Function(String?) onAgentCodeSaved;

  final GlobalKey<FormState> formKey;
  String? selectgenre;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            onSaved: onNameSaved,
            validator: namedValidator.call,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Nom complet",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Man.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: defaultSpacing,
          ),
          TextFormField(
            onSaved: onPhoneSaved,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Le numéro de téléphone est requis";
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "Numéro de téléphone (+243...)",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: Icon(
                  Iconsax.call,
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: defaultSpacing,
          ),
          TextFormField(
            onSaved: onEmailSaved,
            validator: emaildValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: defaultSpacing,
          ),
          TextFormField(
            onSaved: onPasswordSaved,
            validator: passwordValidator.call,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Mot de passe ",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: defaultSpacing,
          ),
          TextFormField(
            onSaved: onConfirmSaved,
            validator: passwordValidator.call,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Confirmé ",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: defaultSpacing,
          ),
          
        ],
      ),
    );
  }
}
