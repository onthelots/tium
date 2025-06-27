import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

Widget buildCachedImage(String url, {BoxFit fit = BoxFit.cover}) {
  return CachedNetworkImage(
    imageUrl: url,
    fit: fit,
    placeholder: (context, url) => Shimmer(
      duration: const Duration(seconds: 2),
      interval: const Duration(seconds: 0),
      color: Colors.grey.shade300,
      colorOpacity: 0.4,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(color: Colors.grey.shade300),
    ),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}
