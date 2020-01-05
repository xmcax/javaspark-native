# JavaSpark + GraalVm Native image

## Build
```
    docker build .
```

## native-image config regeneration

```
java -agentlib:native-image-agent=config-output-dir=json/ -jar javaspark-native-1.0-SNAPSHOT-fatjar.jar
```