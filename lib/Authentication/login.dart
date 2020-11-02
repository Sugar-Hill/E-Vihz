import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminLogin.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}



class _LoginState extends State<Login>
{
  final  GlobalKey<FormState> _formKey=GlobalKey<FormState>();
  final TextEditingController _emailTextEditingController=TextEditingController();
  final TextEditingController _passwordTextEditingController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    double _screenWidth=MediaQuery.of(context).size.width, _screenHeight=MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/login3.png",
                height: 200.0,
                width: 200.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              /*child: Text(
                "Login to your account",
                style: TextStyle(color: Colors.blue[800],fontSize: 15.0),
              ),*/
            ),
            Form(
              key: _formKey,
              child:Column(
                children: [
                  CustomTextField(
                    controller: _emailTextEditingController,
                    data: Icons.email,
                    hintText:"Email" ,
                    isObsecure:false ,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.person,
                    hintText:"Password" ,
                    isObsecure:true ,
                  ),
                ],
              ),
            ),

            RaisedButton(
              onPressed: (){
                _emailTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty
                    ? loginUser()
                    :showDialog(
                    context: context,
                    builder: (c){
                      return ErrorAlertDialog(message: "Please Add Email and Password...",);
                    },
                );
              },
              color: Colors.blue[800],
              child: Text("Login",style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height:50.0 ,
            ),
            Container(
              height: 4.0,
              width: _screenWidth *0.9,
              color: Colors.blue[800],
            ),
            SizedBox(
              height:10.0 ,
            ),
            FlatButton.icon(
              onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminSignInPage())),
              icon: (Icon(Icons.admin_panel_settings_outlined,color: Colors.blue[800],)),
              label: Text("I'm Admin",style:TextStyle(color: Colors.blue[800],fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
  FirebaseAuth _auth=FirebaseAuth.instance;
  void loginUser() async{
    showDialog(
      context: context,
      builder: (c){
        return LoadingAlertDialog(message: "Authenticating, Please Wait...",);
      }
    );
    FirebaseUser firebaseUser;
    await _auth.signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    ).then((authUser){
      firebaseUser=authUser.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c){
            return ErrorAlertDialog(message: error.message.toString(),);
          }
      );
    });
    if(firebaseUser!=null){
      readData(firebaseUser).then((s){
        Navigator.pop(context);
        Route route=MaterialPageRoute(builder: (c)=>StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }
  Future readData(FirebaseUser fUser)async{
    Firestore.instance.collection("users").document(fUser.uid).get().then((dataSnapshot) async {
      await EcommerceApp.sharedPreferences.setString("uid", dataSnapshot.data[EcommerceApp.userUID]);

      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userEmail, dataSnapshot.data[EcommerceApp.userEmail]);
      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName, dataSnapshot.data[EcommerceApp.userName]);
      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, dataSnapshot.data[EcommerceApp.userAvatarUrl]);
      List<String>cartList=dataSnapshot.data[EcommerceApp.userCartList].cast<String>();
      await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList,cartList);
    });
  }
}
