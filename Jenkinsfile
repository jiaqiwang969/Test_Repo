pipeline {
  agent any
  stages {
    stage('Run MATLAB Tests') {
      steps {
        runMATLABCommand 'addpath("main"); results = runtests("IncludeSubfolders", true); assertSuccess(results);'
      }
    }
  }
}
