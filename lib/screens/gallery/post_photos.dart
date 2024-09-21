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
   String? userName;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user's name when the widget is initialized
  }
  User? user;
  // Fetch the user's name from Firestore
  Future<void> _fetchUserName() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid; // Get current user's ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        userName = userDoc['name'];
        email = userDoc['email']; // Fetch the 'email' field
      });
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

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
        'likes': 0, 
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
  Map<String, bool> likedPosts = {}; // Pour stocker l'état de like pour chaque post

  Future<void> _likePost(String postId) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final postRef = FirebaseFirestore.instance
      .collection('posts')
      .doc(userId)
      .collection('userPosts')
      .doc(postId);

  // Vérifiez l'état actuel du like
  bool isLiked = likedPosts[postId] == true;

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentSnapshot postSnapshot = await transaction.get(postRef);
    if (postSnapshot.exists) {
      int newLikes = isLiked ? (postSnapshot['likes'] ?? 0) - 1 : (postSnapshot['likes'] ?? 0) + 1; // Incrémentez ou décrémentez
      transaction.update(postRef, {'likes': newLikes}); // Mettez à jour le champ likes
    }
  });

  // Mettez à jour l'état de liked
  setState(() {
    likedPosts[postId] = !isLiked; // Change l'état du like
  });
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Gallery', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700,color:Color(0xffE6E7E9)))),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Image.asset("assets/icons/back_arrow.png")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40, // Adjust the size as needed
                  backgroundColor: Color(0xff859bb0), // Set the background color
                  child: userName != null
                      ? Text(
                          userName![0].toUpperCase(), // Display the first letter of the user's name
                          style: GoogleFonts.plusJakartaSans(
                              color: Color(0xffCFCFCF), fontSize: 50, fontWeight: FontWeight.w700),
                        )
                      : CircularProgressIndicator(), // Show a loading indicator until the name is fetched
                ),
                SizedBox(width: 10), // Spacing between avatar and column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align the text to the start
                    children: [
                      
                      TextField(
                        controller: _captionController,
                        decoration: InputDecoration(
                          hintText: 'poste etwas, das dir auf dem Herzen liegt!',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: Color(0xffB3B3B3),
                            fontSize: 14,
                            fontWeight: FontWeight.w100,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null, // Allows the text field to expand as needed
                      ),
                      Row(
              children: [
                Expanded(
                  
                  child: GestureDetector(
                    onTap: _pickImage, // Si tu veux que l'image soit cliquable
                    child: Image.asset(
                      'assets/icons/imageChoice.png', // Remplace par le chemin de ton image
                       // Ajuste le mode de couverture de l'image
                    ),
                  ),
                ),

                SizedBox(width: 10),
                Expanded(
                  flex: 4,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _submitPost, // Si l'utilisateur peut cliquer lorsque ce n'est pas en train d'uploader
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white) // Affiche l'indicateur de chargement si en cours d'upload
                          : Text(
                              'Post',
                              style: GoogleFonts.poppins(
                                color: Color(0xff007C7C), // Couleur du texte
                                fontWeight: FontWeight.w500, // Style du texte
                                fontSize: 16, // Taille du texte
                              ),
                            ),
                    ),
                  ),

              ],
            ),

                    ],
                  ),
                ),
              ],
            ),
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
  color: Color(0xff21273D),
  margin: EdgeInsets.symmetric(vertical: 10),
  child: Padding(
    padding: const EdgeInsets.all(10.0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            SizedBox(
              height: 264,
              child: Image.network(
                imageUrl,
                fit: BoxFit.fitWidth,
                width: double.infinity,
              ),
            ),
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
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      '${post['likes']} likes',
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
    ),
    IconButton(
      icon: Icon(
        likedPosts[post.id] == true ? Icons.favorite : Icons.favorite_border,
        color: likedPosts[post.id] == true ? Colors.red : Colors.grey, // Changez la couleur en fonction de l'état
      ),
      onPressed: () {
        _likePost(post.id);
      },
    ),
  ],
),

        ],
      ),
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
