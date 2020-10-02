import 'package:flutter/material.dart';
import 'package:sharelymeter/components/text_field_container.dart';
import 'package:sharelymeter/constants.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hinttext;
  final FormFieldValidator<String> validator;
  
  const RoundedPasswordField({
    Key key, 
    this.onChanged, 
    this.hinttext, 
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: true,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hinttext,
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

