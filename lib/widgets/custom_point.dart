import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomPoint extends StatelessWidget {
  const CustomPoint({
    required this.url,
    required this.scale,
    super.key,
  });

  final String url;
  final double scale;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 88 * scale,
        height: 88 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: -12,
              child: Transform.rotate(
                angle: pi / 4,
                child: Container(
                  height: 22,
                  width: 22,
                  margin: const EdgeInsets.only(bottom: 9, right: 5.5),
                  decoration: BoxDecoration(
                    border: Border.all(width: 8, color: Colors.blue.shade500),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 35 * scale,
                width: 35 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    width: 4,
                    color: Colors.blue.shade500,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    width: 30 * scale,
                    height: 30 * scale,
                    imageUrl: url,
                    placeholder: (context, url) => Image.asset('assets/images/def_avatar_commeta.png'),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.asset('assets/images/def_avatar_commeta.png'),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
