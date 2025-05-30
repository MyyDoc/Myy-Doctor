
import 'package:flutter/material.dart';

class FeedContainerItem extends StatelessWidget {
  const FeedContainerItem({
    super.key,
    required this.textTheme,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage("https://imgs.search.brave.com/Q40jLVzOHGTUVtrYicyrl9Wmxx3nCnz3xr9Crh_Nm_4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvY2xv/c2UtdXAtaW1hZ2Ut/b2YtcGF1bC13YWxr/ZXItb2d1MWRheWd0/YnRramxlei5qcGc"),
                ),
                const SizedBox(width: 10),
                Text(
                  "Antony Maxwell",
                  style: textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Transform.translate(
                  offset: Offset(5, 0),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 300,
            child: Image.network(
              "https://imgs.search.brave.com/8SB8c98eLDaKU2XtzBkYn-3RMNGpc37mjtZVHwmXOHI/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/ZnJlZS1waG90by9h/ZXJpYWwtdmlldy1n/cmVlbi1tb3VudGFp/bm91cy1zY2VuZXJ5/LXN1bnJpc2VfMTgx/NjI0LTEyMzE5Lmpw/Zz9zZW10PWFpc19o/eWJyaWQmdz03NDA",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 13),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                CircleAvatar(radius: 10),
                const SizedBox(width: 5),
                Expanded(
                  flex: 2,
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(text: "shared by "),
                        TextSpan(
                          text: "Mariya",
                          style: textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(text: " and "),
                        TextSpan(
                          text: "222 Others",
                          style: textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.comment_outlined, color: Colors.white,),
                  Icon(Icons.send_rounded, color: Colors.white,),
                  Icon(Icons.bookmark_border_rounded, color: Colors.white,)
                    ],
                  ),
                )
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
