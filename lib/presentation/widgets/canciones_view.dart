import 'package:flutter/material.dart';

class CancionesView extends StatelessWidget {
  const CancionesView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    "https://lh3.googleusercontent.com/xSk9Ej427QD9qTs24NkEQFiU23p8KURWUVcdy-Sp1nU7YaxmeTDstuqm0ot_chPzbogJnnwuWjoXk2Y=w2880-h1200-p-l90-rj",
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "On my way",
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                      Text(
                        "ColdPlay",
                        style: TextStyle(
                            color: Color.fromARGB(255, 100, 100, 100),
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "3:30",
                        style: TextStyle(
                            color: Color.fromARGB(255, 100, 100, 100),
                            fontSize: 15),
                      ),
                      Icon(Icons.explicit)
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.playlist_add),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite),
                )
              ],
            ),
          );
        });
  }
}
