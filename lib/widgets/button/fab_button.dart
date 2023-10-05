// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
 
// import '../../constant/colors.dart';
 

// class FabButton extends StatelessWidget {
 
//   final Color? textColor;
//   final double fontSize;
//  final IconData? icon;
//   final Function()? onPressed;
//   final Color? color;
//   final double? radius;
   
  

//   FabButton({
    
//     required this.onPressed,
//     this.color = AppColors.primaryColor,
//     this.fontSize = 12.0,
//     this.radius = 100.0,
//     this.icon,
//     this.textColor,

   
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         padding: EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color:  color,
//           borderRadius: BorderRadius.circular(radius!.r),
       
//         ),
//         //add svg image here not icon
//       child: SvgPicture.asset(Assets.icons.arrowRight.path, height: 24, width: 24, ), 
        
//     ));
//   }
// }
