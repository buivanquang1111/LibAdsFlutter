
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogLoading{
  late BuildContext mContext;
  showLoading(BuildContext context, String type, String description){
    var descriptionBody;
    mContext = context;

    if(type == "error"){
      descriptionBody = CircleAvatar(
        radius: 100.0,
        maxRadius: 100.0,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.warning),
      );
    } else {
      descriptionBody = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return Dialog.fullscreen(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(description),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
    );
  }

  dismissLoading(){
    Navigator.pop(mContext);
  }
}