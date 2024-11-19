import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart'; // Add this import for Shimmer effect

class PostCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 5.0),
                      Container(
                        width: 60,
                        height: 12,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Container(
                height: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Container(
                    width: 110,
                    height: 32,
                    color: Colors.grey[300],
                  ),
                  const Spacer(),
                  Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
