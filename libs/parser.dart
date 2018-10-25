enum Action{
  train,
  run,
}


class ParsedData{
  
  List<int> topology;
  Action action;
  String inputData;
  String weightFile;
  String outputData;
  bool isOk;

  ParsedData(List<String> args){
    isOk = doTheParsing(args);
  }

  bool doTheParsing(List<String> args){
    if(args.length < 4 ) return false;
    if(args[0] == "train")
      this.action = Action.train;
    else if(args[0] == "run")
      this.action = Action.run;
    else
      return false;
    doTheRest(args);
    return true;
  }

  void doTheRest(List<String> args){
        int i = 3;
        switch (this.action) {
          case Action.train: 
            this.inputData = args[1];
            this.weightFile = args[2];
            break;
          default:
            this.weightFile = args[1];
            this.inputData = args[2];
            this.outputData = args[3];
            i++;
        }
        topology = [];
        while(i < args.length){
          topology.add(int.parse(args[i]));
          i++;
        }
  }

}