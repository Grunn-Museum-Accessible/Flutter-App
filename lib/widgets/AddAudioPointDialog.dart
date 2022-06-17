// import 'dart:convert';
// import 'dart:developer';

// import 'package:app/helpers/globals.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class AddAudioPointDialog extends StatefulWidget {
//   void Function(String? audioFile, num? range) addRoute;
//   AddAudioPointDialog({Key? key, required this.addRoute}) : super(key: key);

//   @override
//   State<AddAudioPointDialog> createState() => _AddAudioPointDialogState();
// }

// class _AddAudioPointDialogState extends State<AddAudioPointDialog> {
//   int selectedAudioItem = -1;
//   List<Map<String, String>>? audio;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     num soundRange = 0;
//     // return AlertDialog();
//     return AlertDialog(
//       title: Text('Add point with audio message'),
//       content: Column(
//         children: [
//           TextField(
//             decoration: InputDecoration(labelText: 'Enter your number'),
//             keyboardType: TextInputType.number,
//             inputFormatters: <TextInputFormatter>[
//               FilteringTextInputFormatter.digitsOnly
//             ],
//             onChanged: (str) {
//               soundRange = num.tryParse(str) ?? 0;
//             },
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             itemCount: audio?.length ?? 0,
//             itemBuilder: (context, index) {
//               // return Text('hello');
//               return ListTile(
//                 tileColor: selectedAudioItem == index
//                     ? Color.fromARGB(255, 163, 161, 161)
//                     : null,
//                 title: Text(audio?[index]['name'] ?? ''),
//                 onTap: () {
//                   log('selected item: ' + index.toString());
//                   setState(() {
//                     selectedAudioItem = index;
//                   });
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       actions: [
//         ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text('cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             widget.addRoute(audio![selectedAudioItem]['path'], soundRange);
//             Navigator.of(context).pop();
//           },
//           child: Text('add'),
//         ),
//       ],
//     );
//     ;
//   }
// }
