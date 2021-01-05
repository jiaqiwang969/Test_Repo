

# MATLAB CI Examples

This repository shows how to run MATLAB tests with a variety of continuous integration systems. 

## Badges

### Jenkins
TBD

### Azure DevOps
[![Azure DevOps Build Status](https://dev.azure.com/sifounak/MATLAB_Test/_apis/build/status/sifounak.Test_Repo?branchName=main)](https://dev.azure.com/sifounak/MATLAB_Test/_build/latest?definitionId=1&branchName=main)
![Azure DevOps Coverage](https://img.shields.io/azure-devops/coverage/sifounak/MATLAB_Test/1/main)

### CircleCI
TBD

### Travis CI
[![Travis CI Build Status](https://travis-ci.com/sifounak/Test_Repo.svg?branch=main)](https://travis-ci.com/sifounak/Test_Repo)


## About the MATLAB code
The repository includes these files:

| **File Path**            | **Description**                                                                                                                                                                    |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `main/sierpinski.m`      | The `sierpinski` function returns a matrix representing an image of a Sierpinski carpet fractal.                                                                                   |
| `test/TestCarpet.m`      | The `TestCarpet` class tests the `sierpinski` function.                                                                                                                            |
| `azure-pipelines.yml`    | The `azure-pipelines.yml` file defines the pipeline that runs on [Azure DevOps](https://marketplace.visualstudio.com/items?itemName=MathWorks.matlab-azure-devops-extension).      |
| `.circleci/config.yml`   | The `config.yml` file defines the pipeline that runs on [CircleCI](https://circleci.com/orbs/registry/orb/mathworks/matlab).                                                       |
| `Jenkinsfile`            | The `Jenkinsfile` file defines the pipeline that runs on [Jenkins](https://plugins.jenkins.io/matlab/).                                                                            |
| `.travis.yml`            | The `.travis.yml` file defines the pipeline that runs on [Travis CI](https://docs.travis-ci.com/user/languages/matlab/).                                                           |

## CI configuration files

### Azure DevOps
```yml
pool:
  vmImage: Ubuntu 16.04
steps:
  - task: InstallMATLAB@0
  - task: RunMATLABTests@0
    inputs:
      sourceFolder: main

  # As an alternative to RunMATLABTests, you can use RunMATLABCommand to execute a MATLAB script, function, or statement.
  # - task: RunMATLABCommand@0
  #   inputs:
  #     command: addpath('main'); results = runtests('IncludeSubfolders', true); assertSuccess(results);
```

### CircleCI
```yml
version: 2.1
orbs:
  matlab: mathworks/matlab@0
  codecov: codecov/codecov@1
jobs:
  build:
    machine:
      image: ubuntu-1604:201903-01
    steps:
      - checkout
      - matlab/install
      - matlab/run-tests:
          source-folder: main

      # As an alternative to run-tests, you can use run-command to execute a MATLAB script, function, or statement.
      # - matlab/run-command:
      #     command: addpath('main'); results = runtests('IncludeSubfolders', true); assertSuccess(results);
```

### Jenkins
```groovy
pipeline {
  agent any
  stages {
    stage('Run MATLAB Tests') {
      steps {
        runMATLABTests(
          sourceFolder: 'main'
        )

        // As an alternative to runMATLABTests, you can use runMATLABCommand to execute a MATLAB script, function, or statement.
        // runMATLABCommand "addpath('main'); results = runtests('IncludeSubfolders', true); assertSuccess(results);"
      }
    }
  }
}
```

### Travis CI
```yml
language: matlab
script: matlab -batch "addpath('main'); results = runtests('IncludeSubfolders', true); assertSuccess(results);"
```

## Caveats
* Currently, MATLAB builds on CircleCI and Travis CI are available only for public projects. MATLAB builds on Azure DevOps that use Microsoft-hosted agents are also available only for public projects.

## Links
- [Continuous Integration with MATLAB and Simulink](https://www.mathworks.com/solutions/continuous-integration.html)

## Contact Us
If you have any questions or suggestions, please contact MathWorks at [continuous-integration@mathworks.com](mailto:continuous-integration@mathworks.com).
