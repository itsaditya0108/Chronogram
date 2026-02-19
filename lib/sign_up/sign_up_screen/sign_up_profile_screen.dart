import 'package:chronogram/buttons/buttons.dart';
import 'package:chronogram/home_screen/home_screen.dart';
import 'package:chronogram/login/login_helper/aseet_helper.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_profile_provider.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpProfileScreen extends StatelessWidget {
  const SignUpProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpProfileProvider(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.read<SignUpProfileProvider>();

//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(ScreenImage.loginBg),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 30),
//             child: Column(
//               children: [
//                 const SizedBox(height: 120),

//                 Image.asset(ScreenImage.allLogoBr, height: 80),
//                 const SizedBox(height: 20),

//                 const Text(
//                   "Complete Profile",
//                   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 10),

//                 const Text(
//                   "Enter your details to continue",
//                   style: TextStyle(color: Colors.black54, fontSize: 16),
//                 ),

//                 const SizedBox(height: 40),

//                 /// NAME
//                 Consumer<SignUpProfileProvider>(
//                   builder: (context, p, child) {
//                     return TextField(
//                       controller: p.nameController,
//                       onChanged: (_) => p.validateName(),
//                       decoration: InputDecoration(
//                         hintText: "Full Name",
//                         errorText: p.nameError,
//                         filled: true,
//                         fillColor: Colors.white38,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 /// DOB
//                 Consumer<SignUpProfileProvider>(
//                   builder: (context, p, child) {
//                     return TextField(
//                       controller: p.dobController,
//                       readOnly: true,
//                       onTap: () async {
//                         DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime(2000),
//                           firstDate: DateTime(1950),
//                           lastDate: DateTime.now(),
//                         );
//                         if (picked != null) {
//                           String month = picked.month.toString().padLeft(
//                             2,
//                             '0',
//                           );
//                           String day = picked.day.toString().padLeft(2, '0');

//                           p.dobController.text = "${picked.year}-$month-$day";

//                           p.validateDob();
//                         }
//                       },
//                       decoration: InputDecoration(
//                         hintText: "Date of Birth",
//                         errorText: p.dobError,
//                         filled: true,
//                         fillColor: Colors.white38,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         suffixIcon: const Icon(Icons.calendar_today),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 40),

//                 /// BUTTON
//                 Consumer<SignUpProfileProvider>(
//                   builder: (context, p, child) {
//                     return AppButton(
//                       title: p.isLoading ? "Please wait..." : "Finish",

//                       onTap: p.isLoading
//                           ? null
//                           : (p.isValid
//                                 ? () async {
//                                     // bool done = await p.completeProfileApi();
//                                     String mobile = context
//                                         .read<SignUpScreenProvider>()
//                                         .mobileController
//                                         .text;

//                                     bool done = await p.completeProfileApi(
//                                       mobile,
//                                     );

//                                     if (done) {
//                                       Navigator.pushAndRemoveUntil(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => HomeScreen(),
//                                         ),
//                                         (route) => false,
//                                       );
//                                     } else {
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text("Profile failed"),
//                                         ),
//                                       );
//                                     }
//                                   }
//                                 : null),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

@override
Widget build(BuildContext context) {
  final provider = context.read<SignUpProfileProvider>();

  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: MediaQuery.of(context).size.height * 0.15),

            /// 🔶 LOGO WITH GLOW
            Center(
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: const Color(0xff1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    ScreenImage.allLogoBr,
                    height: 45,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Complete Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Enter your details to continue",
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 35),

            /// NAME FIELD
            Consumer<SignUpProfileProvider>(
              builder: (context, p, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff1C1C1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: p.nameController,
                    onChanged: (_) => p.validateName(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      hintStyle:
                          const TextStyle(color: Colors.white38),
                      errorText: p.nameError,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// DOB FIELD
            Consumer<SignUpProfileProvider>(
              builder: (context, p, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff1C1C1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: p.dobController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xffFF8C00),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        String month =
                            picked.month.toString().padLeft(2, '0');
                        String day =
                            picked.day.toString().padLeft(2, '0');

                        p.dobController.text =
                            "${picked.year}-$month-$day";

                        p.validateDob();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Date of Birth",
                      hintStyle:
                          const TextStyle(color: Colors.white38),
                      errorText: p.dobError,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            /// FINISH BUTTON
            Consumer<SignUpProfileProvider>(
              builder: (context, p, child) {
                return GestureDetector(
                  onTap: p.isLoading
                      ? null
                      : (p.isValid
                            ? () async {
                                String mobile = context
                                    .read<SignUpScreenProvider>()
                                    .mobileController
                                    .text;

                                bool done =
                                    await p.completeProfileApi(mobile);

                                if (done) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Profile failed"),
                                    ),
                                  );
                                }
                              }
                            : null),
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: p.isValid
                          ? const LinearGradient(
                              colors: [
                                Color(0xffFF8C00),
                                Color(0xffFF5E00),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade800,
                                Colors.grey.shade900,
                              ],
                            ),
                    ),
                    child: Center(
                      child: Text(
                        p.isLoading ? "Please wait..." : "Finish",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            /// STEP PROGRESS (5/5)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 5 / 5),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Step 5 of 5",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(50),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xffFF8C00),
                                  Color(0xffFF5E00),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      "You're all set! 🎉",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}
}