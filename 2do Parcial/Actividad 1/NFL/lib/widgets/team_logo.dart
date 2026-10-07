import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TeamLogo extends StatelessWidget {
  final String url;
  final double size;

  const TeamLogo({super.key, required this.url, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: url.isEmpty
          ? const Icon(Icons.sports_football, size: 32)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.sports_football, size: 32),
            ),
    );
  }
}