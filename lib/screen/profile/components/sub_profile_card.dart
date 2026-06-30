import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gep_point/constants.dart';

class SubProfileCard extends StatelessWidget {
  const SubProfileCard({
    super.key,
    required this.name,
    required this.imageSrc,
    this.press,
    this.isShowHi = true,
  });

  final String name, imageSrc;

  final bool isShowHi;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    print('lurl image est:$imageSrc');
    return Card(
      elevation: 1,
      child: ListTile(
        onTap: press,
        leading: CircleAvatar(
          radius: 15,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: imageSrc.startsWith('http')
                ? Image.network(
                    imageSrc,
                    fit: BoxFit.cover,
                    width: double.maxFinite,
                    height: double.maxFinite,
                  )
                : Image.asset(
                    imageSrc,
                    fit: BoxFit.cover,
                    width: double.maxFinite,
                    height: double.maxFinite,
                  ),
          ),
        ),
        title: SizedBox(
          height: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  isShowHi ? "Hi, $name" : name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: defaultPadding / 2),
            ],
          ),
        ),
        trailing: SvgPicture.asset(
          "assets/icons/miniRight.svg",
          color: (Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.onSurface).withOpacity(0.4),
        ),
      ),
    );
  }
}
