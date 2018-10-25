import 'dart:io';
import 'dart:typed_data';

class DoubleConverter{
    ByteBuffer buffer;
    ByteData bdata;
    DoubleConverter(){
      this.buffer = new Uint8List(8).buffer;
      this.bdata = new ByteData.view(this.buffer);
    }
    List<int> doubleToBytes(double x){
      this.bdata.setFloat64(0, x);
      return this.bdata.buffer.asUint8List();
    }
}

class ByteIOWrite{

  File fileOlder;
  DoubleConverter doubleConverter;
  
  ByteIOWrite(String filePath){
    fileOlder = File(filePath);
    if(fileOlder.existsSync()) fileOlder.delete();
    fileOlder.createSync();

    doubleConverter = new DoubleConverter();

  }

  void addDouble(double x) {
    fileOlder.writeAsBytesSync(doubleConverter.doubleToBytes(x), mode: FileMode.append);
  }
  void addDoubles(List<double> doubles) {
    for( var val in doubles){
      addDouble(val);
    }
  }
}

class ByteIORead{
  
  File        fileOlder;
  List<int>   fileBytes;
  ByteBuffer  buffer;
  ByteData    byteData;
  int         index;
  int         length;
  bool        eof = true;

  ByteIORead(String filePath){
    fileOlder = File(filePath);
    fileBytes = fileOlder.readAsBytesSync();
    buffer = new Int8List.fromList(fileBytes).buffer;
    byteData = new ByteData.view(buffer);
    length = buffer.lengthInBytes;
    index = 0;
    if(length > 0) eof = false;
  }

  double getNext(){
    double result = byteData.getFloat64(index);
    index += 8;
    if(index >= length) eof = true;
    return result;
  }

  List<double> getMultiple(int n){
    List<double> result = [];
    for(var i = 0; i < n; i++){
      if(!eof){
        result.add(getNext());
      }
    }
    return result;
  }

}


main(){

  String file = "test.bin";
  List<double> doubles = [3.14,12.5];

  print(doubles);

  ByteIOWrite btw = new ByteIOWrite(file);
  btw.addDoubles(doubles);
  
  ByteIORead btr = new ByteIORead(file);
  
  print(btr.getMultiple(doubles.length));
}