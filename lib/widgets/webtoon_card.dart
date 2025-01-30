import 'package:flutter/material.dart';
import 'package:toonflix/models/webtoon_model.dart';
import 'package:toonflix/screens/detail_screen.dart';

class WebtoonCard extends StatelessWidget {
  const WebtoonCard({
    super.key,
    required this.webtoon,
  });

  final WebtoonModel webtoon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return DetailScreen(
                webtoon: webtoon,
              );
            },
            fullscreenDialog: true,
          ),
        );
      },
      child: Column(
        children: [
          Hero(
            tag: webtoon.id,
            child: Container(
              width: 250,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    offset: Offset(10, 10),
                    color: Colors.black.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ],
              ),
              child: Image.network(
                webtoon.thumb,
                headers: {
                  "Referer": "https://comic.naver.com",
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            webtoon.title,
            style: TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }
}
