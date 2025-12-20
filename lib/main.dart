import 'package:flutter/material.dart';
import 'package:rentra/core/supabase_client.dart';
import 'package:rentra/Data/repositories/property_repository.dart';
import 'package:rentra/data/datasources/property_remote_datasource.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/UI/screens/property_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection: Create instances of each layer
    final remoteDataSource = PropertyRemoteDataSource();
    final repository = PropertyRepository(remoteDataSource: remoteDataSource);
    final controller = PropertyController(repository: repository);

    return MaterialApp(
      title: 'Property App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PropertyListScreen(propertyController: controller),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:rentra/core/supabase_client.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SupabaseManager.init();
//   runApp(MyApp());
// }

// // Sample Property Model
// class Property {
//   final int id;
//   final String title;
//   final String city;
//   final String imageUrl;

//   Property({
//     required this.id,
//     required this.title,
//     required this.city,
//     required this.imageUrl,
//   });
// }

// class MyApp extends StatelessWidget {
//   //!Sample property list
//   //   final List<Property> properties = [
//   //     Property(
//   //         id: 1,
//   //         title: 'Green Tower',
//   //         city: 'Dhaka',
//   //         imageUrl:
//   //             'https://images.unsplash.com/photo-1572120360610-d971b9c7f9c7'),
//   //     Property(
//   //         id: 2,
//   //         title: 'Sunrise Apartments',
//   //         city: 'Chittagong',
//   //         imageUrl:
//   //             'https://images.unsplash.com/photo-1600585154340-be6161a56a0c'),
//   //     Property(
//   //         id: 3,
//   //         title: 'Blue Sky Residency',
//   //         city: 'Sylhet',
//   //         imageUrl:
//   //             'https://images.unsplash.com/photo-1560185127-6b5c702e9e87'),
//   //   ];
//   //? replacing it with an async function to fectch property data from supabase
//   Future<List<Property>> fetchProperties() async {
//     final response = await SupabaseManager.supabase
//         .from('properties')
//         .select();
//         // .execute();
//     // if (response.error != null) {
//     //   print('Error fetching properties: ${response.error!.message}');
//     //   return [];
//     // }
//     final data = response as List<dynamic>;
//     return data.map((item) {
//       return Property(
//         id: item['id'],
//         title: item['title'],
//         city: item['city'] ?? '',
//         imageUrl: item['image_url'] ?? 'https://via.placeholder.com/150',
//       );
//     }).toList();
//   }

//   MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Property App',
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Public Properties')),
//         body:
//             //! PropertyGrid(properties: properties),
//             //? replacing propertygrid call with async type function
//             FutureBuilder<List<Property>>(
//             future: fetchProperties(),
//             builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                 }else if (snapshot.hasError){
//                     return Center(child: Text('Error ${snapshot.error}'));
//                 }else if(!snapshot.hasData || snapshot.data!.isEmpty){
//                     return const Center(child: Text('No properties found'));
//                 }
//                 final properties = snapshot.data!;
//                 return PropertyGrid(properties: properties);
//                 },
//             ),
//         ),
//     );
//     }
// }

// // Grid to display properties
// class PropertyGrid extends StatelessWidget {
//   final List<Property> properties;

//   const PropertyGrid({super.key, required this.properties});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: properties.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2, // 2 columns
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 3 / 4,
//       ),
//       itemBuilder: (context, index) {
//         final property = properties[index];
//         return GestureDetector(
//           onTap: () {
//             // Print to console when property clicked
//             print('Property clicked: ${property.title}, ${property.city}');
//             // Later you can navigate to PropertyDetailPage
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.grey[200],
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 5,
//                   offset: const Offset(2, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Expanded(
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(12),
//                     ),
//                     child: Image.network(property.imageUrl, fit: BoxFit.cover),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 6,
//                     horizontal: 8,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         property.title,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         property.city,
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
