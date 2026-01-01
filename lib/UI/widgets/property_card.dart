import 'package:flutter/material.dart';
import 'package:rentra/UI/Screens/property_details_screen.dart';
import 'package:rentra/core/models/property.dart';


class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailsScreen(property: property),
          ),
        );
      },
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //! Image takes remaining flexible space
            Expanded(
              child: Image.network(
                property.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            //! Text section keeps minimum height
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}