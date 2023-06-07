// if (snapshot.connectionState == ConnectionState.waiting) {
// return const Center(
// child: CircularProgressIndicator(
// color: Colors.white,
// ),
// );
// } else if (snapshot.hasData && snapshot.data!.isEmpty) {
// return const Center(
// child: Text(
// "No members found",
// style: TextStyle(color: Colors.white),
// ),
// );
// } else if (snapshot.hasData) {
// return Padding(
// padding: EdgeInsets.only(left: 20.0, right: 20),
// child: ListView.builder(
// itemCount: snapshot.data!.length,
// itemBuilder: (context, index) {
// // ...
// },
// ),
// );
// } else if (snapshot.hasError) {
// return const Center(
// child: Text(
// "Error occurred while fetching data",
// style: TextStyle(color: Colors.white),
// ),
// );
// } else {
// return const Center(
// child: Text(
// "Something went wrong",
// style: TextStyle(color: Colors.white),
// ),
// );
// }