// class ResetPasswordPage extends StatefulWidget {
//   final String? email;

//   ResetPasswordPage({this.email});

//   @override
//   _ResetPasswordPageState createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final TextEditingController newPasswordController = TextEditingController();

//   Future<void> _changePassword() async {
//     if (newPasswordController.text.isEmpty) {
//       // Tampilkan dialog jika kata sandi kosong
//       return;
//     }

//     try {
//       // Ganti kata sandi pengguna
//       User? user = FirebaseAuth.instance.currentUser;
//       await user?.updatePassword(newPasswordController.text);
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Sukses"),
//           content: Text("Kata sandi berhasil diperbarui!"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.popUntil(context, (route) => route.isFirst); // Kembali ke halaman awal
//               },
//               child: Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       // Tampilkan pesan error jika pembaruan gagal
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Gagal mengubah kata sandi: ${e.toString()}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Reset Password")),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: newPasswordController,
//               decoration: InputDecoration(hintText: "Kata Sandi Baru"),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _changePassword,
//               child: Text("Ubah Kata Sandi"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
