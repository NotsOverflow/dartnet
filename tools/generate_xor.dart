import 'dart:io';
import 'dart:math';
import '../libs/byteio.dart';

class RandomXorGate {

  int input1;
  int input2;
  int output;

  Random random;

  RandomXorGate({seed = 5555}){
    this.random = new Random();
    this.random = new Random(this.random.nextInt(seed));
    this.next();
  }

  List<int> next(){
    this.input1 = random.nextInt(2);
    this.input2 = random.nextInt(2);
    this.output = this.input1 ^ this.input2;
    return [this.input1, this.input2, this.output];
  }



  void echo({bool verbose = true}){
    if(verbose){
      print("input 1 => ${this.input1.toString()}");
      print("input 2 => ${this.input2.toString()}");
      print("result  => ${this.output.toString()}");
    }
    else{
      print("${this.input1.toString()} ${this.input2.toString()} ${this.output.toString()}");
    }
  }

}


void main(List<String> args) {

  if(args.length != 2){
    print("\n\t!!! Only 2 arguments are requered: 'filepath' and 'number of data' !!!\n");
    exit(1);
  }

  String filePath = args[0];
  int nbOfData = int.parse(args[1]);
  RandomXorGate gate = new RandomXorGate();
  ByteIOWrite btw = ByteIOWrite(filePath);

  stdout.write("Generating ${nbOfData} XOR data into ${filePath}...");

  for(var i = 0; i < nbOfData; i++){
    //gate.echo(verbose: false);
    btw.addDoubles([gate.input1 + .0, gate.input2 + .0, gate.output + .0]);
    gate.next();
  }

  print(" done!");

}