import 'package:flutter/material.dart';

class ArtistasView extends StatelessWidget {
  const ArtistasView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 20,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ClipOval(
                    child: Image.network(
                      "https://lh3.googleusercontent.com/xSk9Ej427QD9qTs24NkEQFiU23p8KURWUVcdy-Sp1nU7YaxmeTDstuqm0ot_chPzbogJnnwuWjoXk2Y=w2880-h1200-p-l90-rj",
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                    child: Text("ColdPlay"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
