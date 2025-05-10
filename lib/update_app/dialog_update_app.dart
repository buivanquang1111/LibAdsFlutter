import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogUpdateApp extends StatelessWidget {
  final String? title;
  final String? content;
  final Function() onUpdateNow;

  const DialogUpdateApp({super.key, this.title, this.content, required this.onUpdateNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      // color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? '🚀 New Update Available!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xff2B2B2B), fontSize: 21, decoration: TextDecoration.none),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  content ??
                      'Upgrade now for a smoother experience, bug fixes for better performance. ⚡',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xff9F9F9F), fontSize: 14, decoration: TextDecoration.none),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: onUpdateNow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffFF617F),
                            Color(0xffFF0F3D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Update Now',
                            style: TextStyle(
                                color: Color(0xffFFFFFF),
                                fontSize: 14,
                                decoration: TextDecoration.none),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
