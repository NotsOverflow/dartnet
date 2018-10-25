import 'dart:math';
import 'connection.dart';



num tanh(num x) => -1.0 + 2.0 / (1 + pow(e,(-2 * x)));

class Neron{
  
  bool bias;
  double output_val;
  double gradient;
  int   index;
  double eta;
  double alpha;
  Function activationF;
  Function derivativeF;

  List<Connection> output_weight = [];

  Neron(int index, int nbOutputs, Function rnd ,{bias=false, output_val=1.0, activationFunction = null, derivativeFunction = null, eta = 0.15, alpha = 0.5}){

    this.index = index;
    this.bias = bias;
    this.output_val = output_val;
    this.alpha = alpha;
    this.eta = eta;

    activationF = activationFunction == null ? this.defaultActivationFunction : activationFunction;
    derivativeF = derivativeFunction == null ? this.defaultDerivativeFunction : derivativeFunction;


    if(bias) rnd = (){return 1.0;};
    
    
    for(var i = 0; i < nbOutputs; i++){
      output_weight.add(new Connection(rnd(),0.0));
    }
  }

  void recalculateOutput(List<Neron> prevLayer){

    double output = 0.0;

    for (var neron = 0; neron < prevLayer.length; neron++) {
      output += prevLayer[neron].output_val * prevLayer[neron].output_weight[this.index].weight;
    }
    output_val = activationFunction(output);
  }
    
  double activationFunction(double x) {
    // tanh => [-1.0..1.0]
    return activationF(x);
    //return tanh(x);
  }
  double defaultActivationFunction(double x) {
    // tanh => [-1.0..1.0]
    return ( 1 - exp( -2 * x ) ) / ( 1 + exp( -2 * x ) );
    //return tanh(x);
  }
  double activationFunctionDerivative(double x) {
    //simplification
    return derivativeF(x);
    //return 1.0 - ( tanh(x) * tanh(x) );
  }

  double defaultDerivativeFunction(double x) {
    //simplification
    return 1.0 - ( x * x );
    //return 1.0 - ( tanh(x) * tanh(x) );
  }
  double sumDOW(List<Neron> layer){
    double sum = 0.0;
    for(var neronIndex = 0; neronIndex < layer.length - 1; neronIndex++){
      sum += output_weight[neronIndex].weight * layer[neronIndex].gradient;
    }
    return sum;
  }

  void calculateOutputGradiens(double targetValue){
      double delta = targetValue - output_val;
      gradient = delta * activationFunctionDerivative(output_val);
  }
  void calculateHiddenGradiens(List<Neron> nextLayer){
    double dow = sumDOW(nextLayer);
    gradient = dow * activationFunctionDerivative(output_val);
  }
  List<Neron> updateWeitghs(List<Neron> previousLayer){
    for(var neronIndex = 0; neronIndex < previousLayer.length; neronIndex++){
      double oldDeltaWeight = previousLayer[neronIndex].output_weight[this.index].deltaWeight;
      
      double newDeltaWeight = 
        eta * previousLayer[neronIndex].output_val
        * gradient + alpha * oldDeltaWeight;

      previousLayer[neronIndex].output_weight[this.index].deltaWeight = newDeltaWeight;
      previousLayer[neronIndex].output_weight[this.index].weight += newDeltaWeight;
    }
    return previousLayer;
  }

}