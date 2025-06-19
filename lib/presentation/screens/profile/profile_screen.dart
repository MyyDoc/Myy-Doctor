import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ThemeData
    final textTheme = Theme.of(context).textTheme; // TextTheme
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1F323C),
        title: Row(
          children: [
            Text(
              "Antony Maxwell",
              style: textTheme.titleLarge!.copyWith(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
          ],
        ),
        leading: Icon(Icons.lock_person_rounded, color: Colors.amber),
        automaticallyImplyLeading: false,
        actions: [
          Icon(Icons.add_box_outlined, color: Color(0xFFD4AF37), size: 30),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.message_outlined,
              color: Color(0xFFD4AF37),
              size: 30,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFCDE4EA)],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 50),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    // Each column holds number + label
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "10",
                                          style: textTheme.titleLarge!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25
                                          )
                                        ),
                                        Text("Posts",
                                        style: textTheme.titleMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "150",
                                          style: textTheme.titleLarge!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25
                                          )
                                        ),
                                        Text("Followers", style: textTheme.titleMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "50",
                                          style: textTheme.titleLarge!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25
                                          )
                                        ),
                                        Text("Following", style: textTheme.titleMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "80",
                                          style: textTheme.titleLarge!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25
                                          )
                                        ),
                                        Text("Subscribers", style: textTheme.titleMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color:  Color(0xFF1F323C),
                                        ),
                                        child: Text("Edit Profile", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),),
                                      ),
                                    ),
                                    const SizedBox(width: 15,),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color:  Color(0xFF1F323C),
                                        ),
                                        child: Text("Subscriber Chat", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [

                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
