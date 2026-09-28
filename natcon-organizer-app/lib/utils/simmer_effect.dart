import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


Widget commonSimmer({required double height, required double width,double? radius,BorderRadiusGeometry? customGeometry}) {
  return Shimmer.fromColors(
    baseColor: Colors.black45,
    highlightColor: Colors.grey.shade100,
    enabled: true,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: customGeometry ?? BorderRadius.circular(radius ?? 12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [],
      ),
    ),
  );
}