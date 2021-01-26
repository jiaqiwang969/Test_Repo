

# MATLAB CI Examples

This repository shows how to run MATLAB tests with a variety of continuous integration systems.

## Badges

### Jenkins
TBD

### Azure DevOps
[![Azure DevOps Build Status](https://dev.azure.com/sifounak/MATLAB_Test/_apis/build/status/sifounak.Test_Repo?branchName=main)](https://dev.azure.com/sifounak/MATLAB_Test/_build/latest?definitionId=1&branchName=main)
![Azure DevOps Coverage](https://img.shields.io/azure-devops/coverage/sifounak/MATLAB_Test/1/main)
[Blog with helpful information for setting up Azure DevOps badges](https://gregorsuttie.com/2019/03/20/azure-devops-add-your-build-status-badges-to-your-wiki/)

### CircleCI
[![CircleCI Build Badge](https://circleci.com/gh/sifounak/Test_Repo.svg?style=shield)](https://app.circleci.com/pipelines/github/sifounak/Test_Repo)
[CircleCI documentation for setting up badges](https://circleci.com/docs/2.0/status-badges/#generating-a-status-badge "CircleCI documentation for setting up badges")

### Travis CI
[![Travis CI Build Status](https://travis-ci.com/sifounak/Test_Repo.svg?style=svg?branch=main)](https://travis-ci.com/sifounak/Test_Repo)
[Travis CI documentation for setting up badges](https://docs.travis-ci.com/user/status-images/ "Travis CI documentation for setting up badges")

### GitHub A
![MATLAB](https://github.com/acampbel/Test_Repo/workflows/MATLAB/badge.svg)
[GitHub Actions documentation for setting up badges](https://docs.github.com/en/actions/managing-workflow-runs/adding-a-workflow-status-badge)

## About the code
The repository includes these files:

| **File Path**              | **Description**                                                                                                                                                                    |
|----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `main/sierpinski.m`        | The `sierpinski` function returns a matrix representing an image of a Sierpinski carpet fractal.                                                                                   |
| `test/TestCarpet.m`        | The `TestCarpet` class tests the `sierpinski` function.                                                                                                                            |
| `azure-pipelines.yml`      | The `azure-pipelines.yml` file defines the pipeline that runs on [Azure DevOps](https://marketplace.visualstudio.com/items?itemName=MathWorks.matlab-azure-devops-extension).      |
| `.circleci/config.yml`     | The `config.yml` file defines the pipeline that runs on [CircleCI](https://circleci.com/orbs/registry/orb/mathworks/matlab).                                                       |
| `Jenkinsfile`              | The `Jenkinsfile` file defines the pipeline that runs on [Jenkins](https://plugins.jenkins.io/matlab/).                                                                            |
| `.travis.yml`              | The `.travis.yml` file defines the pipeline that runs on [Travis CI](https://docs.travis-ci.com/user/languages/matlab/).
| `.github/workflows/ci.yml` | The `ci.yml` file defines the pipeline that runs on [GitHub Actions](https://github.com/matlab-actions/overview).

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

### GitHub Actions
```yml
# This is a basic workflow to help you get started with MATLAB Actions

name: MATLAB

# Controls when the action will run. 
on:
  # Triggers the workflow on push or pull request events but only for the main branch
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
      
      # Sets up MATLAB on the GitHub Actions runner
      - name: Setup MATLAB
        uses: matlab-actions/setup-matlab@v0

      # Runs a set of commands using the runners shell
      - name: Run all tests
        uses: matlab-actions/run-tests@v0
        with:
          source-folder: main

      # As an alternative to run-tests, you can use run-command to execute a MATLAB script, function, or statement.
      #- name: Run all tests
      #  uses: matlab-actions/run-command@v0
      #  with:
      #    command: addpath('main'); results = runtests('IncludeSubfolders', true); assertSuccess(results);
```



## Caveats
* Currently, MATLAB builds on Travis CI are available only for public projects. MATLAB builds on Azure DevOps, CircleCI, and GitHub Actions that use CI service-hosted agents are also available only for public projects. However, these integrations can be used in private porjecrts that leverage self-hosted runners/agents.

## Links
- [Continuous Integration with MATLAB and Simulink](https://www.mathworks.com/solutions/continuous-integration.html)

## Contact Us
If you have any questions or suggestions, please contact MathWorks at [continuous-integration@mathworks.com](mailto:continuous-integration@mathworks.com).
