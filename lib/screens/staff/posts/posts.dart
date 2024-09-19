import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPostsPage extends StatefulWidget {
  @override
  _AdminPostsPageState createState() => _AdminPostsPageState();
}

class _AdminPostsPageState extends State<AdminPostsPage> {
  Future<void> _updatePostStatus(String userId, String postId, bool posted) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(userId)
        .collection('userPosts')
        .doc(postId)
        .update({'posted': posted});
  }

  Future<void> _deletePost(String userId, String postId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(userId)
        .collection('userPosts')
        .doc(postId)
        .delete();
  }

Future<List<Map<String, dynamic>>> _getAllPosts() async {
  try {
    final userDocs = await FirebaseFirestore.instance.collection('users').get();
    print('Number of user documents: ${userDocs.docs.length}'); // Log pour vérifier le nombre de documents
    
    List<Map<String, dynamic>> allPosts = [];
    
    for (var userDoc in userDocs.docs) {
      final userId = userDoc.id;
      print('Fetching posts for userId: $userId'); // Log pour vérifier les IDs
      
      final userPosts = await FirebaseFirestore.instance
          .collection('posts')
          .doc(userId)
          .collection('userPosts')
          .get();
      
      print('User posts count for $userId: ${userPosts.docs.length}'); // Log pour vérifier le nombre de posts
      
      for (var postDoc in userPosts.docs) {
        allPosts.add({
          'userId': userId,
          'postId': postDoc.id,
          ...postDoc.data() as Map<String, dynamic>,
        });
      }
    }
    return allPosts;
  } catch (e) {
    print('Error fetching posts: $e'); // Log pour vérifier les erreurs
    return [];
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'All Posts',
            style: GoogleFonts.plusJakartaSans(
              color: Color(0xffE6E7E9),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
       
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts found.'));
          }

          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final userId = post['userId'] as String;
              final postId = post['postId'] as String;
              final bool isPosted = post['posted'] ?? false;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Color(0xff1A1C20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post['imageUrl'] != null)
                        Image.network(post['imageUrl']),
                      if (post['caption'] != null)
                        Text(
                          post['caption'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (post['timestamp'] != null)
                        Text(
                          'Posted on: ${DateTime.fromMillisecondsSinceEpoch(post['timestamp'].millisecondsSinceEpoch).toLocal()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.0,
                            color: Colors.grey[400],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _updatePostStatus(userId, postId, !isPosted);
                            },
                            child: Text(isPosted ? 'Unpost' : 'Post'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPosted ? Colors.red : Colors.green,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              _deletePost(userId, postId);
                            },
                            child: Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
