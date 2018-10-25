import '../libs/byteio.dart';
import 'dart:io';

void main(List<String> args){

  if(args.length != 3){
    print("\n\t!!! Only 3 arguments are requered: 'filepath' 'nbInputs' 'nbOutputs' !!!\n");
    exit(1);
  }


  ByteIORead byteIORead = ByteIORead(args[0]);
  int inputs = int.parse(args[1]);
  int outputs = int.parse(args[2]);
  
  while(byteIORead.eof != true){
    print("inputs  => ${byteIORead.getMultiple(inputs)}");
    print("outputs => ${byteIORead.getMultiple(outputs)}");
    print("------------------");
  }
}