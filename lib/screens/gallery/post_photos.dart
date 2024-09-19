import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _captionController = TextEditingController();
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child(userId)
          .child(fileName);

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    final imageUrl = await _uploadImage(_image!);
    final caption = _captionController.text;

    if (imageUrl != null) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final postsRef = FirebaseFirestore.instance.collection('posts').doc(userId).collection('userPosts');

      await postsRef.add({
        'imageUrl': imageUrl,
        'caption': caption,
        'timestamp': Timestamp.now(),
        'posted':false,
      });

      setState(() {
        _isUploading = false;
        _image = null;
        _captionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post uploaded successfully!')));
    } else {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload post')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      hintStyle: GoogleFonts.poppins(),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_image != null)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _image = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.photo, color: Color(0xFF91306a)),
                    label: Text('Add Photo', style: GoogleFonts.poppins(color: Color(0xFF91306a))),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF91306a)),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submitPost,
                    child: _isUploading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Post', style: GoogleFonts.poppins(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF91306a),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator(color: Colors.white));
      }

      final userDocs = snapshot.data!.docs;

      if (userDocs.isEmpty) {
        return Center(child: Text('No posts available.', style: TextStyle(color: Colors.white)));
      }

      // Collect all posts from each user's userPosts collection where posted is true
      return FutureBuilder<List<QuerySnapshot>>(
        future: Future.wait(userDocs.map((userDoc) async {
          final userId = userDoc.id;
          return FirebaseFirestore.instance
              .collection('posts')
              .doc(userId)
              .collection('userPosts')
              .where('posted', isEqualTo: true) // Filtrer par le champ 'posted'
              .get();
        })),
        builder: (context, futureSnapshot) {
          if (futureSnapshot.hasError) {
            return Center(child: Text('Error: ${futureSnapshot.error}'));
          }
          if (!futureSnapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final posts = futureSnapshot.data!
              .expand((snapshot) => snapshot.docs)
              .toList();

          if (posts.isEmpty) {
            return Center(child: Text('No posts available.', style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final imageUrl = post['imageUrl'];
              final caption = post['caption'];
              final timestamp = post['timestamp'].toDate();

              return Card(
                color: Color(0xFF91306a),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        Image.network(imageUrl),
                      SizedBox(height: 10),
                      Text(
                        caption,
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Posted by: ',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  ),
),

          ],
        ),
      ),
    );
  }
}
