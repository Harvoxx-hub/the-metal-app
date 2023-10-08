import 'package:flutter/material.dart';

class BaseTextField extends StatelessWidget {
  const BaseTextField({super.key

, required this.hintText, required this.controller, this.obscureText = false, this.keyboardType = TextInputType.text, required this.validator, required this.onChanged, required this.onFieldSubmitted, required this.onTap, required this.onEditingComplete, required this.onSaved

  });
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String) validator;
  final Function(String) onChanged;
  final Function(String) onFieldSubmitted;
  final Function() onTap;
  final Function() onEditingComplete;
  final Function() onSaved;
 
 



  @override
  Widget build(BuildContext context) {
    return  TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
     
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
    
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}