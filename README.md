# DartNet
Dart Deep Neural Network


### Test it
```bash

# generate a Xor dataset of 2500 data ( in, in, out )
dart .\tools\generate_xor.dart small.bin 2500

# train net [2,4,1] with small.bin dataset and save weights
dart .\main.dart train small.bin weight.bin 2 4 

# use it!
dart .\main.dart run weight.bin small.bin out.bin 2 4 1

```

### Use as lib
```dart
    import 'libs/net.dart';
    
    Net neuralNet = new Net([3,6,8,1]);

    neuralNet.loadWeights("weightFile");
    neuralNet.feedForward([0.2, 0.8, 1.0]);

    List<double> result = neuralNet.getResults();

```
