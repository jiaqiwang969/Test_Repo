pipeline {
  agent any
  stages {
    stage('Run MATLAB Tests') {
      steps {
        runMATLABTests(
          sourceFolder: main
        )
        runMATLABCommand addpath('main'); results = runtests('IncludeSubfolders', true); assertSuccess(results);
      }
    }
  }
}
