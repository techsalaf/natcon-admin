import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'Colors.dart';


Widget commonSimmer({required double height, required double width,double? radius,BorderRadiusGeometry? customGeometry}) {
  return Shimmer.fromColors(
    baseColor: Colors.black45,
    highlightColor: Colors.grey.shade100,
    enabled: true,
    child: Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bordercolor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.withOpacity(0.3),
          ),

          const SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                color: Colors.grey.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 20,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}