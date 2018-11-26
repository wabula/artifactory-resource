# Artifactory Resource

Deploys and retrieves artifacts from a JFrog Artifactory server for a Concourse pipeline.

To define an Artifactory resource for a Concourse pipeline:

``` yaml
resource_types:
- name: artifactory
  type: docker-image
  source:
    repository: pivotalservices/artifactory-resource

resources:
- name: file-repository
  type: artifactory
  source:
    endpoint: http://ARTIFACTORY-HOST-NAME-GOES-HERE:8081/artifactory
    repository: "/repository-name/sub-folder"
    regex: "myapp-(?<version>.*).txt"
    username: YOUR-ARTIFACTORY-USERNAME
    password: YOUR-ARTIFACTORY-PASSWORD
    skip_ssl_verification: true
```

## Source Configuration

* `endpoint`: *Required.* The Artifactory REST API endpoint. eg. http://YOUR-HOST_NAME:8081/artifactory.
* `repository`: *Required.* The Artifactory repository which includes any folder path, must contain a leading '/'. ```eg. /generic/product/pcf```
* `regex`: *Required.* Regular expression used to extract artifact version, must contain 'version' group and match the entire filename. ```E.g. myapp-(?<version>.*).tar.gz```
* `username`: *Optional.* Username for HTTP(S) auth when accessing an authenticated repository
* `password`: *Optional.* Password for HTTP(S) auth when accessing an authenticated repository
* `skip_ssl_verification`: *Optional.* Skip ssl verification when connecting to Artifactory's APIs. Values: ```true``` or ```false```(default).

## Parameter Configuration

* `file`: *Required for put* The file to upload to Artifactory
* `regex`: *Optional* overrides the source regex
* `folder`: *Optional.* appended to the repository in source - must start with forward slash /
* `skip_download`: *Optional.* skip download of file. Useful for improving put performance by skipping the implicit get step using [get_params](https://concourse.ci/put-step.html#put-step-get-params).

Saving/deploying an artifact to Artifactory in a pipeline job:

``` yaml
  jobs:
  - name: build-and-save-to-artifactory
    plan:
    - task: build-a-file
      config:
        platform: linux
        image_resource:
          type: docker-image
          source:
            repository: ubuntu
        outputs:
        - name: build
        run:
          path: sh
          args:
          - -exc
          - |
            export DATESTRING=$(date +"%Y%m%d")
            echo "This is my file" > ./build/myapp-$(date +"%Y%m%d%H%S").txt
            find .
    - put: file-repository
      params: { file: ./build/myapp-*.txt }
```

Retrieving an artifact from Artifactory in a pipeline job:

``` yaml
jobs:
- name: trigger-when-new-file-is-added-to-artifactory
  plan:
  - get: file-repository
    trigger: true
  - task: use-new-file
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: ubuntu
      inputs:
      - name: file-repository
      run:
        path: echo
        args:
        - "Use file(s) from ./file-repository here..."
```

See [pipeline.yml](https://github.com/pivotalservices/artifactory-resource/blob/develop/example/pipeline.yml) for an example of a full pipeline definition file.

## Resource behavior

### `check`: ...

Relies on the regex to retrieve artifact versions


### `in`: ...

Same as check, but retrieves the artifact based on the provided version


### `out`: Deploy to a repository.

Deploys the artifact.

#### Parameters

* `file`: *Required.* The path to the artifact to deploy.

## Development

### Build Docker image

Run the following command in the root folder:
```
$ docker build -t username/artifactory-resource .
```

### Running tests

The test suite consists of a mixture of unit and integration tests.

The unit test suite requires [bats](https://github.com/bats-core/bats-core) to be [installed](https://github.com/bats-core/bats-core#installation).

For example, to execute the unit tests for `common.sh` functions:
```
$ bats test/common.bats
```

In order to run the integration tests, you must be running Artifactory on port 8081. The easiest way
to do that is to run Artifactory in a [Docker container](https://www.jfrog.com/confluence/display/RTF/Installing+with+Docker):
```
$ docker run --name artifactory -d -p 8081:8081 docker.bintray.io/jfrog/artifactory-oss:latest
```

Then you need to run a script to seed it with test data:
```
TBD
```

To run the integration test suite (which is in the container image at /opt/resource-tests):
```
$ docker run -it \
  --env ART_IP=127.0.0.1 \
  --env ART_USER=admin \
  --env ART_PWD=admin \
  username/artifactory-resource:latest \
  /opt/resource-tests/test-check.sh

$ docker run -it \
  --env ART_IP=127.0.0.1 \
  --env ART_USER=admin \
  --env ART_PWD=admin \
  username/artifactory-resource:latest \
  /opt/resource-tests/test-in.sh

$ docker run -it \
  --env ART_IP=127.0.0.1 \
  --env ART_USER=admin \
  --env ART_PWD=admin \
  username/artifactory-resource:latest \
  /opt/resource-tests/test-out.sh
```

Or you can build `Dockerfile.tests` to run all tests:
```
$ docker build -f Dockerfile.tests \
  --build-arg ART_IP=127.0.0.1 \
  --build-arg ART_USER=admin \
  --build-arg ART_PWD=admin \
  -t username/artifactory-resource:test .
```

## Credits
This resource was originally based on the artifactory resource work of [mborges](https://github.com/mborges-pivotal/artifactory-resource).
