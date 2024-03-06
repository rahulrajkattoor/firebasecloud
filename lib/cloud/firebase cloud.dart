import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyDB8T4rmn9qt5HeiPz1hHR0-bzgnpuTA0k",
        appId: "1:817342645783:android:074487a01e119f9a29fe52",
        messagingSenderId: "",
        projectId: "cloud-e86c6",
      storageBucket: "cloud-e86c6.appspot.com"
    )
  );
  runApp(MaterialApp(home: cloud(),));
}
class cloud extends StatefulWidget{
  @override
  State<cloud> createState() => _cloudState();
}

class _cloudState extends State<cloud> {
  var name_controller=TextEditingController();
  var email_controller=TextEditingController();
  late CollectionReference _userCollection;
  @override
  void initState(){
    _userCollection=FirebaseFirestore.instance.collection("user");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.purpleAccent,title: Text("Firebase cloud"),titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
     body:Padding(
       padding: EdgeInsets.all(15),
       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           TextField(
             controller: name_controller,
             decoration: InputDecoration(
               labelText: "name",border: OutlineInputBorder()
             ),
           ),
           SizedBox(height: 15,),
           TextField(
             controller: email_controller,
             decoration: InputDecoration(
               labelText: "email",border: OutlineInputBorder()
             ),
           ),
           SizedBox(height: 15,),
           ElevatedButton(onPressed: (){
             addUser();
           }, child: Text("Add user")),
           SizedBox(height: 15,),
           StreamBuilder(stream: getUser(), builder: (context,snapshot){
             if(snapshot.hasError){
               return Text("Error${snapshot.error}");
             }if(snapshot.connectionState==ConnectionState.waiting){
               return CircularProgressIndicator();
             }
             final users= snapshot.data!.docs;
             return Expanded(child:ListView.builder(
               itemCount: users.length,
                 itemBuilder: (context,index){
               final user=users[index];
               final userId=user.id;
               final userName=user['name'];
               final userEmail=user['email'];
               return ListTile(
                 title: Text('$userName',style: TextStyle(fontSize: 20),),
                 subtitle: Text("$userEmail",style: TextStyle(fontSize: 15),),
                 trailing: Wrap(
                   children: [
                     IconButton(onPressed: (){
                       editUser(userId);
                     }, icon: Icon(Icons.edit)),
                     IconButton(onPressed: (){
                       deleteUser(userId);
                     }, icon: Icon(Icons.delete))
                   ],
                 ),
               );

             }));
           })
         ],
       ),
     ) ,
    );

  }
  ///create user
  Future<void>addUser()async {
    return _userCollection.add({
      'name': name_controller.text,
      'email': email_controller.text
    }).then((value) {
      print("user added succesfully");
      name_controller.clear();
      email_controller.clear();
    }).catchError((error) {
      print("failed to add user $error");
    });

  }
  Stream<QuerySnapshot>getUser(){
    return _userCollection.snapshots();
  }
  Future<void>updateUser(var id,String newname,String newemail){
    return _userCollection
        .doc(id)
        .update({'name':newname,"email":newemail}).then((value){
          print("user updated succesfully");
    }).catchError((error){
      print("user data updation failed $error");
    });
  }
  Future<void>deleteUser(var id){
    return _userCollection.doc(id).delete().then((value){
      print("user deleted succesfully");
    }).catchError((error){
      print("user deletion failed $error");
    });
  }



  void editUser(var id){
    showDialog(context: context, builder: (context) {
      final newname_controller=TextEditingController();
      final newemail_controller=TextEditingController();
      return AlertDialog(
        title: Text("Updatae user"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newname_controller,
              decoration: InputDecoration(hintText: "Enter name",border: OutlineInputBorder()),
            ),
            SizedBox(height: 15,),
            TextField(
              controller: newemail_controller,
              decoration: InputDecoration(hintText: "Enter email",border: OutlineInputBorder()),
            )
          ],

        ),
        actions: [
          TextButton(onPressed: (){
            updateUser(id,newname_controller.text,newemail_controller.text).then((value){
              Navigator.pop(context);
            });
          }, child:Text("Update") )
        ],
      );
    });
  }
}