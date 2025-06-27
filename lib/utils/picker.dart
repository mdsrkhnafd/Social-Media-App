import 'package:image_picker/image_picker.dart';

pickImage() async {
  final ImagePicker picker = ImagePicker();
  // Pick an image
  final XFile? image = await picker.pickImage(source: ImageSource.camera);
  if (image != null) {
    return image;
  }
}