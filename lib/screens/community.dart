import 'dart:convert';
import 'package:flutter/material.dart';
import 'navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/auth_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _postController = TextEditingController();
  List posts = [];
  String? currentUserId;
  String selectedSort = 'Newest';
  bool showMyPosts = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId');
    });
    await fetchAllPosts();
  }

  Future<void> fetchAllPosts() async {
    final res = showMyPosts
        ? await AuthService.getMyPosts()
        : await AuthService.getAllPosts();

    if (res.statusCode == 200) {
      List loadedPosts = json.decode(res.body);

      if (selectedSort == 'Most Commented') {
        loadedPosts.sort((a, b) =>
            (b['commentsCount'] ?? 0).compareTo(a['commentsCount'] ?? 0));
      } else if (selectedSort == 'Most Related') {
        loadedPosts.sort((a, b) =>
            (b['relates']?.length ?? 0).compareTo(a['relates']?.length ?? 0));
      } else {
        loadedPosts.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));
      }

      setState(() {
        posts = loadedPosts;
      });
    }
  }

  void showCreatePostPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Create Post",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                fontFamily: 'Onest-VariableFont_wght')),
        content: TextField(
          controller: _postController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "What’s on your mind?",
            filled: true,
            fillColor: const Color(0xFFF9F6F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await createPost();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDECEBE),
              foregroundColor: Colors.white,
            ),
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  Future<void> createPost() async {
    if (_postController.text.isEmpty) return;
    final res = await AuthService.createPost(_postController.text);
    if (res.statusCode == 201) {
      _postController.clear();
      fetchAllPosts();
    }
  }

  void showCommentPopup(String postId) {
    List comments = [];
    final TextEditingController commentController = TextEditingController();

    Future<void> fetchComments(StateSetter localSetState) async {
      final response = await AuthService.getComments(postId);
      localSetState(() {
        comments = response.statusCode == 200 ? json.decode(response.body) : [];
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Comments",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.w400)),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDECEBE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFDECEBE), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, localSetState) {
                    fetchComments(localSetState); // fetch on open

                    return Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDECEBE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            final res = await AuthService.addComment(
                              postId,
                              commentController.text,
                            );
                            if (res.statusCode == 201) {
                              commentController.clear();
                              await fetchComments(localSetState);
                              fetchAllPosts();
                            }
                          },
                          child: const Text("Post Comment"),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (ctx, i) {
                              final comment = comments[i];
                              final canDelete =
                                  comment['user']['_id'] == currentUserId;
                              final createdAt = comment['createdAt'] ??
                                  DateTime.now().toString();

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Color(0xFFDECEBE)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment['user']['name'] ?? 'User',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF4B3621),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            comment['text'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontFamily:
                                                  'Onest-VariableFont_wght',
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            timeago.format(
                                                DateTime.parse(createdAt)),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (canDelete)
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            final TextEditingController
                                                editController =
                                                TextEditingController(
                                                    text: comment['text']);

                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                title: const Text(
                                                  "Edit Comment",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontFamily:
                                                          'Onest-VariableFont_wght'),
                                                ),
                                                content: TextField(
                                                  controller: editController,
                                                  maxLines: 4,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Update your comment...",
                                                    filled: true,

                                                    fillColor: Color(
                                                        0xFFF9F6F2), // ✅ Background of TextField

                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .black), // ✅ Black text
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      final res =
                                                          await AuthService
                                                              .editComment(
                                                        comment['_id'],
                                                        editController.text,
                                                      );
                                                      if (res.statusCode ==
                                                          200) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        await fetchComments(
                                                            localSetState);
                                                        fetchAllPosts();
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFDECEBE),
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    child: const Text("Save"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          if (value == 'delete') {
                                            final shouldDelete =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                title: const Text(
                                                  "Delete Comment",
                                                  style: TextStyle(
                                                      color: Color(0xFF4B3621)),
                                                ),
                                                content: const Text(
                                                  "Are you sure you want to delete this comment?",
                                                  style: TextStyle(
                                                      color: Colors.black87),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child: const Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .black), // ✅ Black text
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFDECEBE),
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child: const Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .black), // ✅ Black text
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (shouldDelete == true) {
                                              final res = await AuthService
                                                  .deleteComment(
                                                      comment['_id']);
                                              if (res.statusCode == 200) {
                                                await fetchComments(
                                                    localSetState);
                                                fetchAllPosts();
                                              }
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit,
                                                    color: Color.fromARGB(
                                                        0, 12, 12, 12),
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Text("Edit"),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    color: Color.fromARGB(
                                                        0, 12, 12, 12),
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Text("Delete"),
                                              ],
                                            ),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.black54),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ buildPostCard & build() remain unchanged (keep yours here)

  // ✅ Your buildPostCard & build() remain unchanged

  Widget buildPostCard(post) {
    final content = post['content'] ?? '';
    final creator = post['user'];
    final creatorName = creator?['name'] ?? 'User';
    final creatorId = creator?['_id'];
    final List<dynamic> relates = post['relates'] ?? [];
    final relatesCount = relates.length;
    final commentsCount = post['commentsCount'] ?? 0;
    final createdAt = post['createdAt'];
    final canDelete = currentUserId != null && currentUserId == creatorId;
    final userReacted = relates.any((r) {
      final id = r is String ? r : r['_id'];
      return id == currentUserId;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, // ❌ No background tint
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDECEBE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creatorName,
                    style: const TextStyle(
                      fontFamily: "Onest-VariableFont_wght",
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Color(0xFF4B3621),
                    ),
                  ),
                  Text(
                    timeago.format(DateTime.parse(createdAt)),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              if (canDelete)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      await AuthService.deletePost(post['_id']);
                      fetchAllPosts();
                    }
                  },
                  color: Colors.white, // ✅ Menu background is now white
                  shape: RoundedRectangleBorder(
                    // ✅ Rounded corners
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 6),
                          Text("Delete Post"),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(content,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Onest-VariableFont_wght',
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  await AuthService.relatePost(post['_id']);
                  await fetchAllPosts();
                },
                icon: Icon(
                  userReacted ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                label: Text("Relate ($relatesCount)",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 75, 33, 33))),
              ),
              TextButton.icon(
                onPressed: () => showCommentPopup(post['_id']),
                icon: const Icon(Icons.mode_comment_outlined,
                    color: Color(0xFF4B3621)),
                label: Text("Comment ($commentsCount)",
                    style: const TextStyle(color: Color(0xFF4B3621))),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(currentIndex: 1, onTap: (index) {}),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            const Center(
              child: Text("Community",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Onest-VariableFont_wght',
                      color: Color(0xFF4B3621))),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: InkWell(
                onTap: showCreatePostPopup,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF), // soft light beige
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFDECEBE),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note,
                          size: 36, color: Color(0xFFB8A89D)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Share something with the community…",
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Onest-VariableFont_wght',
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(30),
                      isSelected: [!showMyPosts, showMyPosts],
                      onPressed: (index) {
                        setState(() {
                          showMyPosts = index == 1;
                          fetchAllPosts();
                        });
                      },
                      selectedColor: Colors.white,
                      color: const Color(0xFF4B3621),
                      fillColor: const Color(0xFFDECEBE),
                      selectedBorderColor: const Color(0xFFDECEBE),
                      borderColor: const Color(0xFFB8A89D),
                      children: const [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text("All Posts"),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text("My Posts"),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFB8A89D)),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(canvasColor: Colors.white),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSort,
                            borderRadius: BorderRadius.circular(22),
                            onChanged: (value) {
                              setState(() {
                                selectedSort = value!;
                                fetchAllPosts();
                              });
                            },
                            items: ['Newest', 'Most Commented', 'Most Related']
                                .map((String sortType) =>
                                    DropdownMenuItem<String>(
                                      value: sortType,
                                      child: Text(
                                        sortType,
                                        style: const TextStyle(
                                            fontFamily: 'Gayathri'),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) => buildPostCard(posts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'navbar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import '../services/auth_service.dart';

// class CommunityPage extends StatefulWidget {
//   const CommunityPage({super.key});

//   @override
//   State<CommunityPage> createState() => _CommunityPageState();
// }

// class _CommunityPageState extends State<CommunityPage> {
//   final TextEditingController _postController = TextEditingController();
//   final TextEditingController _commentController = TextEditingController();
//   List posts = [];
//   String? currentUserId;
//   String selectedSort = 'Newest';
//   bool showMyPosts = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }

//   Future<void> fetchUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       currentUserId = prefs.getString('userId');
//     });
//     await fetchAllPosts();
//   }

//   Future<void> fetchAllPosts() async {
//     final res = showMyPosts
//         ? await AuthService.getMyPosts()
//         : await AuthService.getAllPosts();

//     if (res.statusCode == 200) {
//       List loadedPosts = json.decode(res.body);

//       if (selectedSort == 'Most Commented') {
//         loadedPosts.sort((a, b) =>
//             (b['commentsCount'] ?? 0).compareTo(a['commentsCount'] ?? 0));
//       } else if (selectedSort == 'Most Related') {
//         loadedPosts.sort((a, b) =>
//             (b['relates']?.length ?? 0).compareTo(a['relates']?.length ?? 0));
//       } else {
//         loadedPosts.sort((a, b) => DateTime.parse(b['createdAt'])
//             .compareTo(DateTime.parse(a['createdAt'])));
//       }

//       setState(() {
//         posts = loadedPosts;
//       });
//     }
//   }

//   void showCreatePostPopup() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Create Post",
//             style: TextStyle(
//                 fontWeight: FontWeight.w300,
//                 fontFamily: 'Onest-VariableFont_wght')),
//         content: TextField(
//           controller: _postController,
//           maxLines: 4,
//           decoration: InputDecoration(
//             hintText: "What’s on your mind?",
//             filled: true,
//             fillColor: const Color(0xFFF9F6F2),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text(
//               "Cancel",
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await createPost();
//               Navigator.of(context).pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFDECEBE),
//               foregroundColor: Colors.white,
//             ),
//             child: const Text("Post"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> createPost() async {
//     if (_postController.text.isEmpty) return;
//     final res = await AuthService.createPost(_postController.text);
//     if (res.statusCode == 201) {
//       _postController.clear();
//       fetchAllPosts();
//     }
//   }

//   void showCommentPopup(String postId) async {
//     _commentController.clear();
//     final response = await AuthService.getComments(postId);
//     List comments =
//         response.statusCode == 200 ? json.decode(response.body) : [];

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       isScrollControlled: true,
//       builder: (_) => Padding(
//         padding: MediaQuery.of(context).viewInsets,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text("Comments",
//                   style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400)),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _commentController,
//                 decoration: InputDecoration(
//                   hintText: "Write a comment...",
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: Color(0xFFDECEBE)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide:
//                         const BorderSide(color: Color(0xFFDECEBE), width: 1.5),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFDECEBE),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 onPressed: () async {
//                   final res = await AuthService.addComment(
//                     postId,
//                     _commentController.text,
//                   );
//                   if (res.statusCode == 201) {
//                     Navigator.of(context).pop();
//                     fetchAllPosts();
//                   }
//                 },
//                 child: const Text("Post Comment"),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 height: 200,
//                 child: ListView.builder(
//                   itemCount: comments.length,
//                   itemBuilder: (ctx, i) {
//                     final comment = comments[i];
//                     final canDelete = comment['user']['_id'] == currentUserId;
//                     final createdAt =
//                         comment['createdAt'] ?? DateTime.now().toString();

//                     return Container(
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Color(0xFFFFFFFF),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Color(0xFFDECEBE)),
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   comment['user']['name'] ?? 'User',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                     color: Color(0xFF4B3621),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   comment['text'] ?? '',
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontFamily: 'Onest-VariableFont_wght',
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   timeago.format(DateTime.parse(createdAt)),
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//             if (canDelete)
//                             Theme(
//                               data: Theme.of(context).copyWith(
//                                 popupMenuTheme: PopupMenuThemeData(
//                                   color: Colors
//                                       .white, // ✅ White background for popup menu
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         12), // ✅ Rounded corners
//                                   ),
//                                 ),
//                               ),
//                               child: PopupMenuButton<String>(
//                                 onSelected: (value) async {
//                                   if (value == 'delete') {
//                             final shouldDelete = await showDialog<bool>(
//                                       context: context,
//                                       builder: (context) => Theme(
//                                         data: Theme.of(context).copyWith(
//                                           dialogBackgroundColor: Colors
//                                               .white, // ✅ This forces background to white
//                                         ),
//                                         child: AlertDialog(
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                                 16), // ✅ Rounded corners
//                                           ),
//                                           title: const Text(
//                                             "Delete Comment",
//                                             style: TextStyle(
//                                                 color: Color(0xFF4B3621)),
//                                           ),
//                                           content: const Text(
//                                             "Are you sure you want to delete this comment?",
//                                             style: TextStyle(
//                                                 color: Colors.black87),
//                                           ),
//                                           actions: [
//                                             TextButton(
//                                               child: const Text(
//                                                 "Cancel",
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               onPressed: () =>
//                                                   Navigator.pop(context, false),
//                                             ),
//                                             ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor:
//                                                     const Color(0xFFDECEBE),
//                                               ),
//                                               child: const Text(
//                                                 "Delete",
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               onPressed: () =>
//                                                   Navigator.pop(context, true),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );

//                                     if (shouldDelete == true) {
//                                       final res =
//                                           await AuthService.deleteComment(
//                                               comment['_id']);
//                                       if (res.statusCode == 200) {
//                                         fetchAllPosts();
//                                         Navigator.pop(context);
//                                       }
//                                     }
//                                   }
//                                 },
//                                 itemBuilder: (context) => [
//                                   const PopupMenuItem<String>(
//                                     value: 'delete',
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.delete_outline_rounded,
//                                             color: Colors.red, size: 18),
//                                         SizedBox(width: 8),
//                                         Text("Delete"),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                                 icon: const Icon(Icons.more_vert,
//                                     color: Colors.black54),
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildPostCard(post) {
//     final content = post['content'] ?? '';
//     final creator = post['user'];
//     final creatorName = creator?['name'] ?? 'User';
//     final creatorId = creator?['_id'];
//     final List<dynamic> relates = post['relates'] ?? [];
//     final relatesCount = relates.length;
//     final commentsCount = post['commentsCount'] ?? 0;
//     final createdAt = post['createdAt'];
//     final canDelete = currentUserId != null && currentUserId == creatorId;
//     final userReacted = relates.any((r) {
//       final id = r is String ? r : r['_id'];
//       return id == currentUserId;
//     });

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white, // ❌ No background tint
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFDECEBE), width: 1.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//          Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     creatorName,
//                     style: const TextStyle(
//                       fontFamily: "Onest-VariableFont_wght",
//                       fontWeight: FontWeight.w500,
//                       fontSize: 18,
//                       color: Color(0xFF4B3621),
//                     ),
//                   ),
//                   Text(
//                     timeago.format(DateTime.parse(createdAt)),
//                     style: const TextStyle(fontSize: 13, color: Colors.black54),
//                   ),
//                 ],
//               ),
//               if (canDelete)
//                 PopupMenuButton<String>(
//                   onSelected: (value) async {
//                     if (value == 'delete') {
//                       await AuthService.deletePost(post['_id']);
//                       fetchAllPosts();
//                     }
//                   },
//                   color: Colors.white, // ✅ Menu background is now white
//                   shape: RoundedRectangleBorder(
//                     // ✅ Rounded corners
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   itemBuilder: (context) => [
//                     const PopupMenuItem<String>(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete, color: Colors.red, size: 18),
//                           SizedBox(width: 6),
//                           Text("Delete Post"),
//                         ],
//                       ),
//                     ),
//                   ],
//                   icon: const Icon(Icons.more_vert, color: Colors.black54),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(content,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontFamily: 'Onest-VariableFont_wght',
//               )),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               TextButton.icon(
//                 onPressed: () async {
//                   await AuthService.relatePost(post['_id']);
//                   await fetchAllPosts();
//                 },
//                 icon: Icon(
//                   userReacted ? Icons.favorite : Icons.favorite_border,
//                   color: Colors.red,
//                 ),
//                 label: Text("Relate ($relatesCount)",
//                     style: const TextStyle(
//                         color: Color.fromARGB(255, 75, 33, 33))),
//               ),
//               TextButton.icon(
//                 onPressed: () => showCommentPopup(post['_id']),
//                 icon: const Icon(Icons.mode_comment_outlined,
//                     color: Color(0xFF4B3621)),
//                 label: Text("Comment ($commentsCount)",
//                     style: const TextStyle(color: Color(0xFF4B3621))),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       bottomNavigationBar: BottomNavBar(currentIndex: 1, onTap: (index) {}),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 15),
//             const Center(
//               child: Text("Community",
//                   style: TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.w400,
//                       fontFamily: 'Onest-VariableFont_wght',
//                       color: Color(0xFF4B3621))),
//             ),
//             const SizedBox(height: 6),
//             GestureDetector(
//               onTap: showCreatePostPopup,
//               child: const Text("What’s on your mind?",
//                   style: TextStyle(
//                       fontSize: 20,
//                       fontFamily: 'Gayathri',
//                       color: Colors.black)),
//             ),
//             const SizedBox(height: 12),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: Row(
//                   children: [
//                     ToggleButtons(
//                       borderRadius: BorderRadius.circular(30),
//                       isSelected: [!showMyPosts, showMyPosts],
//                       onPressed: (index) {
//                         setState(() {
//                           showMyPosts = index == 1;
//                           fetchAllPosts();
//                         });
//                       },
//                       selectedColor: Colors.white,
//                       color: const Color(0xFF4B3621),
//                       fillColor: const Color(0xFFDECEBE),
//                       selectedBorderColor: const Color(0xFFDECEBE),
//                       borderColor: const Color(0xFFB8A89D),
//                       children: const [
//                         Padding(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           child: Text("All Posts"),
//                         ),
//                         Padding(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           child: Text("My Posts"),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 12),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Color(0xFFB8A89D)),
//                         borderRadius: BorderRadius.circular(22),
//                       ),
//                       child: Theme(
//                         data: Theme.of(context)
//                             .copyWith(canvasColor: Colors.white),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: selectedSort,
//                             borderRadius: BorderRadius.circular(22),
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedSort = value!;
//                                 fetchAllPosts();
//                               });
//                             },
//                             items: ['Newest', 'Most Commented', 'Most Related']
//                                 .map((String sortType) =>
//                                     DropdownMenuItem<String>(
//                                       value: sortType,
//                                       child: Text(
//                                         sortType,
//                                         style: const TextStyle(
//                                             fontFamily: 'Gayathri'),
//                                       ),
//                                     ))
//                                 .toList(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: posts.length,
//                 itemBuilder: (context, index) => buildPostCard(posts[index]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:timeago/timeago.dart' as timeago;
// // import '../services/auth_service.dart';
// // import 'navbar.dart';

// // class CommunityPage extends StatefulWidget {
// //   const CommunityPage({super.key});

// //   @override
// //   State<CommunityPage> createState() => _CommunityPageState();
// // }

// // class _CommunityPageState extends State<CommunityPage> {
// //   final TextEditingController _postController = TextEditingController();
// //   final TextEditingController _commentController = TextEditingController();
// //   List posts = [];
// //   String? currentUserId;
// //   String selectedSort = 'Newest';
// //   bool showMyPosts = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchUserData();
// //   }

// //   Future<void> fetchUserData() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       currentUserId = prefs.getString('userId');
// //     });

// //     await fetchAllPosts();
// //   }

// //   Future<void> fetchAllPosts() async {
// //     final res = showMyPosts
// //         ? await AuthService.getMyPosts()
// //         : await AuthService.getAllPosts();

// //     print("📦 Response status: ${res.statusCode}");
// //     print("📩 Response body: ${res.body}");

// //     if (res.statusCode == 200) {
// //       List loadedPosts = json.decode(res.body);

// //       // Sorting...
// //       if (selectedSort == 'Most Commented') {
// //         loadedPosts.sort((a, b) =>
// //             (b['commentsCount'] ?? 0).compareTo(a['commentsCount'] ?? 0));
// //       } else if (selectedSort == 'Most Related') {
// //         loadedPosts.sort((a, b) =>
// //             (b['relates']?.length ?? 0).compareTo(a['relates']?.length ?? 0));
// //       } else {
// //         loadedPosts.sort((a, b) => DateTime.parse(b['createdAt'])
// //             .compareTo(DateTime.parse(a['createdAt'])));
// //       }

// //       setState(() {
// //         posts = loadedPosts;
// //       });
// //     }
// //   }

// //   Future<void> createPost() async {
// //     if (_postController.text.isEmpty) return;
// //     final res = await AuthService.createPost(_postController.text);
// //     if (res.statusCode == 201) {
// //       _postController.clear();
// //       fetchAllPosts();
// //     }
// //   }

// //   void showCommentPopup(String postId) async {
// //     _commentController.clear();
// //     final response = await AuthService.getComments(postId);
// //     List comments =
// //         response.statusCode == 200 ? json.decode(response.body) : [];

// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: Colors.white,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
// //       ),
// //       isScrollControlled: true,
// //       builder: (_) => Padding(
// //         padding: MediaQuery.of(context).viewInsets,
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               const Text("Comments", style: TextStyle(fontSize: 18)),
// //               TextField(
// //                 controller: _commentController,
// //                 decoration: InputDecoration(
// //                   hintText: "Write a comment...",
// //                   filled: true,
// //                   fillColor: Colors.grey[100],
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide.none,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.white,
// //                   foregroundColor: const Color(0xFFD7A68D),
// //                 ),
// //                 onPressed: () async {
// //                   final res = await AuthService.addComment(
// //                       postId, _commentController.text);
// //                   if (res.statusCode == 201) {
// //                     Navigator.of(context).pop();
// //                     fetchAllPosts();
// //                   }
// //                 },
// //                 child: const Text("Post Comment"),
// //               ),
// //               const SizedBox(height: 10),
// //               SizedBox(
// //                 height: 200,
// //                 child: ListView.builder(
// //                   itemCount: comments.length,
// //                   itemBuilder: (ctx, i) {
// //                     final comment = comments[i];
// //                     final canDelete = comment['user']['_id'] == currentUserId;

// //                     return ListTile(
// //                       title: Text(
// //                         comment['user']['name'] ?? 'User',
// //                         style: const TextStyle(fontWeight: FontWeight.bold),
// //                       ),
// //                       subtitle: Text(
// //                         comment['text'] ?? '',
// //                         style: const TextStyle(fontSize: 16),
// //                       ),
// //                       trailing: canDelete
// //                           ? IconButton(
// //                               icon: const Icon(Icons.delete, color: Colors.red),
// //                               onPressed: () async {
// //                                 try {
// //                                   final commentId = comment['_id'];
// //                                   print(
// //                                       "🗑️ Trying to delete comment with ID: $commentId");

// //                                   final response =
// //                                       await AuthService.deleteComment(
// //                                           commentId);

// //                                   print(
// //                                       "🔎 Status Code: ${response.statusCode}");
// //                                   print("📩 Body: ${response.body}");

// //                                   if (response.statusCode == 200) {
// //                                     print("✅ Comment deleted successfully");
// //                                     fetchAllPosts();
// //                                   } else {
// //                                     print(
// //                                         "🧨 Failed to delete comment: ${response.body}");
// //                                   }
// //                                 } catch (e) {
// //                                   print(
// //                                       "🚨 Exception while deleting comment: $e");
// //                                 }
// //                               })
// //                           : null, // Show delete button only for comment owner
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget buildPostCard(post) {
// //     final content = post['content'] ?? '';
// //     final creator = post['user'];
// //     final creatorName = creator?['name'] ?? 'User';
// //     final creatorId = creator?['_id'];
// //     final List<dynamic> relates = post['relates'] ?? [];
// //     final relatesCount = relates.length;
// //     final commentsCount = post['commentsCount'] ?? 0;
// //     final createdAt = post['createdAt'];
// //     final canDelete = currentUserId != null && currentUserId == creatorId;

// //     final userReacted = relates.any((r) {
// //       final id = r is String ? r : r['_id'];
// //       return id == currentUserId;
// //     });

// //     return AnimatedSlide(
// //       offset: const Offset(0, 0),
// //       duration: const Duration(milliseconds: 300),
// //       child: Container(
// //         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           color: Colors.white, // White background for the card
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.1),
// //               blurRadius: 6,
// //               offset: const Offset(0, 3),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(creatorName,
// //                         style: const TextStyle(
// //                             fontWeight: FontWeight.bold, fontSize: 16)),
// //                     Text(timeago.format(DateTime.parse(createdAt)),
// //                         style: const TextStyle(
// //                             color: Colors.black54, fontSize: 12))
// //                   ],
// //                 ),
// //                 if (canDelete)
// //                   PopupMenuButton<String>(
// //                     // For post deletion
// //                     onSelected: (value) async {
// //                       if (value == 'delete') {
// //                         await AuthService.deletePost(post['_id']);
// //                         fetchAllPosts(); // Fetch posts after deletion
// //                       }
// //                     },
// //                     itemBuilder: (context) => [
// //                       const PopupMenuItem<String>(
// //                         // Post delete option
// //                         value: 'delete',
// //                         child: Row(
// //                           children: [
// //                             Icon(Icons.delete, color: Colors.red, size: 18),
// //                             SizedBox(width: 6),
// //                             Text("Delete Post"),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                     icon: const Icon(Icons.more_vert, color: Colors.black54),
// //                   )
// //               ],
// //             ),
// //             const SizedBox(height: 10),
// //             Text(content,
// //                 style: const TextStyle(
// //                   fontSize: 15,
// //                   // fontFamily:
// //                   //     'Gayathri', // Apply the Gayathri font to the post content
// //                   fontWeight: FontWeight.bold, // Make the font bold
// //                 )),
// //             const SizedBox(height: 12),
// //             Row(
// //               children: [
// //                 TextButton.icon(
// //                   onPressed: () async {
// //                     await AuthService.relatePost(post['_id']);
// //                     await fetchAllPosts();
// //                   },
// //                   icon: Icon(
// //                     userReacted ? Icons.favorite : Icons.favorite_border,
// //                     color: Colors.red,
// //                   ),
// //                   label: Text(
// //                     "Relate ($relatesCount)",
// //                     style: const TextStyle(
// //                         color: Colors.black,
// //                         // fontFamily: 'Gayathri',
// //                         fontWeight: FontWeight.bold),
// //                   ),
// //                 ),
// //                 TextButton.icon(
// //                   onPressed: () => showCommentPopup(post['_id']),
// //                   icon: const Icon(Icons.mode_comment_outlined,
// //                       color: Colors.black),
// //                   label: Text(
// //                     "Comment ($commentsCount)",
// //                     style: const TextStyle(
// //                         color: Colors.black,
// //                         // fontFamily: 'Gayathri',
// //                         fontWeight: FontWeight.bold),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       bottomNavigationBar: BottomNavBar(
// //         currentIndex: 2,
// //         onTap: (index) {
// //           // Handle bottom nav tap if needed
// //         },
// //       ),
// //       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Padding(
// //                 padding: EdgeInsets.only(left: 120.0),
// //                 child: Text(
// //                   'Community',
// //                   style: TextStyle(
// //                     color: Colors.brown,
// //                     fontSize: 35,
// //                     fontFamily: 'Gayathri',
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextField(
// //                         controller: _postController,
// //                         decoration: InputDecoration(
// //                           hintText: "What’s on your mind?",
// //                           filled: true,
// //                           fillColor: Colors.grey[200],
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(16),
// //                             borderSide: BorderSide.none,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     FloatingActionButton(
// //                       mini: true,
// //                       backgroundColor: Colors.white,
// //                       onPressed: createPost,
// //                       child: const Icon(Icons.send, color: Color(0xFFD7A68D)),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                 children: [
// //                   ToggleButtons(
// //                     borderRadius: BorderRadius.circular(20),
// //                     isSelected: [!showMyPosts, showMyPosts],
// //                     onPressed: (index) {
// //                       setState(() {
// //                         showMyPosts = index == 1;
// //                         print("🔄 showMyPosts = $showMyPosts");

// //                         fetchAllPosts();
// //                       });
// //                     },
// //                     selectedColor: Colors.white, // Text color when selected
// //                     color: Colors.black, // Default text color for unselected
// //                     fillColor:
// //                         Color(0xFFD7A68D), // Background color when selected
// //                     hoverColor:
// //                         Color(0xFFD7A68D).withOpacity(0.3), // Hover color
// //                     children: const [
// //                       Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 12),
// //                         child: Text("All Posts"),
// //                       ),
// //                       Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 12),
// //                         child: Text("My Posts"),
// //                       ),
// //                     ],
// //                   ),
// //                   DropdownButton<String>(
// //                     value: selectedSort,
// //                     dropdownColor: Colors.white,
// //                     onChanged: (value) {
// //                       setState(() {
// //                         selectedSort = value!;
// //                         fetchAllPosts();
// //                       });
// //                     },
// //                     items: ['Newest', 'Most Commented', 'Most Related']
// //                         .map((String sortType) => DropdownMenuItem<String>(
// //                               value: sortType,
// //                               child: Text(sortType),
// //                             ))
// //                         .toList(),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 10),
// //               Expanded(
// //                 child: ListView.builder(
// //                   itemCount: posts.length,
// //                   itemBuilder: (context, index) => buildPostCard(posts[index]),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
