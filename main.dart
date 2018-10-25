import 'libs/net.dart';
import 'libs/parser.dart';
import 'libs/byteio.dart';


void train(ParsedData data,{bool resume = true, bool save = true}){

  Net neuralNet = new Net(data.topology);
  ByteIORead btr = ByteIORead(data.inputData);
  List<double> samples;
  
  if(resume) neuralNet.loadWeights(data.weightFile);
  while(btr.eof != true){
    print("training");
    
    samples = btr.getMultiple(data.topology[0]);
    print("Inputs => ${samples}");
    neuralNet.feedForward(samples);
    
    samples = neuralNet.getResults();
    print("Got => ${samples}");

    samples = btr.getMultiple(data.topology.last);
    print("Presume => ${samples}");

    neuralNet.backProp(samples);
    print("Error: ${neuralNet.recentAverageError}");
  }
  if(save) neuralNet.saveWeights(data.weightFile);
}


void run(ParsedData data){

  Net neuralNet = new Net(data.topology);
  ByteIORead btr = ByteIORead(data.inputData);
  ByteIOWrite btw = ByteIOWrite(data.outputData);
  List<double> samples;

  neuralNet.loadWeights(data.weightFile);

  while(btr.eof != true){
    print("Running");
    samples = btr.getMultiple(data.topology[0]);
    print("Inputs => ${samples}");
    neuralNet.feedForward(samples);
    samples = neuralNet.getResults();
    print("Got => ${samples}");
    btw.addDoubles(samples);
  }

}


void main(List<String> args) {

  ParsedData data = new ParsedData(args);
  if(data.isOk != true){
    print("Usage:\n");
    print("\tProgram train <inputData> <outPutWeights> [ topology ]");
    print("\tProgram run   <inputWeights> <inputData> <outputData> [ topology ]");
    print("Example:\n");
    print("\tProgram run weights.bin inputs.bin output.bin 2 3 4 1\n");
  }

  switch (data.action) {
    case Action.train:
      train(data);    
      break;
    case Action.run:
      run(data);    
      break;
  }

}