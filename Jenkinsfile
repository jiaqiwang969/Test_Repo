pipeline {
  agent any
  stages {
    stage('error') {
      steps {
        runMATLABCommand 'addpath("main"); results = runtests("IncludeSubfolders", true); assertSuccess(results);'
      }
    }

  }
}