import 'neuron.dart';
import 'dart:math';
import 'byteio.dart';

class Net{
  
  List<int> topology;
  List<List<Neron>> net = [];
  double error;
  double recentAverageError = 0.0 ;
  double recentAverageSmoothingFactor = 0.0;

  Net(List<int> topology, { double eta = 0.15, double alpha = 0.5, Function activationFunction = null, Function derivativeFunction = null,}){
    this.topology = topology;
    if(this.topology.length < 2)
      throw("some arbitrary error");
    _buildNet(eta, alpha, activationFunction, derivativeFunction);

  }

  void _buildNet(double eta, double alpha, Function activationFunction, Function derivativeFunction){
    
    Random rnd = new Random(1337);
    rnd = new Random(rnd.nextInt(5555));

    this.topology.asMap().forEach((index, nbNeurons) {
      List<Neron> layer = [];
      int nbWeight = index == this.topology.length - 1 ? 0 : this.topology[index + 1] ;

      for(var neronNum = 0; neronNum < nbNeurons; neronNum++){
        layer.add(new Neron(
          neronNum,
          nbWeight,
          rnd.nextDouble,
          eta: eta,
          alpha: alpha,
          activationFunction:activationFunction,
          derivativeFunction: derivativeFunction,
        ));
      }
      layer.add(new Neron(
        nbNeurons,
        nbWeight,
        rnd.nextDouble,
        bias: true,
        eta: eta,
        alpha: alpha,
        activationFunction:activationFunction,
        derivativeFunction: derivativeFunction,
      ));
      net.add(layer);
    });
  }

  void feedForward(List<double> inputVals){
      assert(inputVals.length == this.net[0].length - 1);

      inputVals.asMap().forEach((index, value) {
        net[0][index].output_val = value;
      });

      for (var layerNum = 1; layerNum < net.length; layerNum++) {
        for (var neron = 0; neron < net[layerNum].length - 1; neron++) {
          net[layerNum][neron].recalculateOutput(net[layerNum-1]);
        }
      }
  }

  void backProp(List<double> targetVals){
    assert(targetVals.length == this.net.last.length - 1);

    error = 0.0;
    
    for (var neronIndex = 0; neronIndex < net.last.length - 1; neronIndex++) {
      double delta = targetVals[neronIndex] - net.last[neronIndex].output_val;
      error += delta * delta;
    }
    error /= net.last.length - 1;
    error = sqrt(error);

    recentAverageError = (recentAverageError * recentAverageSmoothingFactor + error)
    / (recentAverageError + 1.0);

    for(var neronIndex = 0; neronIndex < net.last.length - 1 ; neronIndex++){
      net.last[neronIndex].calculateOutputGradiens(targetVals[neronIndex]);
    }

    for (var layerIndex = net.length - 2 ; layerIndex > 0 ; layerIndex--) {
      for (var neuronIndex = 0; neuronIndex < net[layerIndex].length; neuronIndex++) {
        net[layerIndex][neuronIndex].calculateHiddenGradiens(net[layerIndex + 1]);
      }
    }

    for (var layerIndex = net.length - 1 ; layerIndex > 0 ; layerIndex--) {
      for (var neuronIndex = 0; neuronIndex < net[layerIndex].length - 1; neuronIndex++) {
        net[layerIndex][neuronIndex].updateWeitghs(net[layerIndex - 1]);
      }
    }

  }

  List<double> getResults(){

    List<double> resultsVals = [];

    for(var neronIndex = 0; neronIndex < net.last.length -1 ; neronIndex++){
        resultsVals.add(net.last[neronIndex].output_val);
    }

    return resultsVals;
  }

  void saveWeights(String filePath){
    
    ByteIOWrite byteIOWrite = ByteIOWrite(filePath);

    for (var layer = 0; layer < this.net.length; layer++) {
      for (var neron = 0; neron < this.net[layer].length; neron++) {
        List<double> weights = [];
        for (var connection = 0; connection < this.net[layer][neron].output_weight.length; connection++) {
          weights.add(this.net[layer][neron].output_weight[connection].weight);
          weights.add(this.net[layer][neron].output_weight[connection].deltaWeight);
        }
        byteIOWrite.addDoubles(weights);
      }
    }
  }

  void loadWeights(String filePath){
    ByteIORead byteIORead = ByteIORead(filePath);
    
    for (var layer = 0; layer < this.net.length; layer++) {
      for (var neron = 0; neron < this.net[layer].length; neron++) {
        List<double> weights;
        for (var connection = 0; connection < this.net[layer][neron].output_weight.length; connection++) {
          weights = byteIORead.getMultiple(2);
          this.net[layer][neron].output_weight[connection].weight = weights[0];
          this.net[layer][neron].output_weight[connection].deltaWeight = weights[1];
        }
      }
    }
  }


}