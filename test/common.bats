#!/usr/bin/env bats

@test "applyRegex_version returns version" {
  source assets/common.sh

  export regex="myapp-(?<version>.*).txt"
  export file_name="myapp-0.1.1.txt"

  run applyRegex_version "$regex" "$file_name"
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.1" ]
}

@test "get_current_version returns expected version" {
  source assets/common.sh

  export regex="myapp-(?<version>.*).txt"
  export expected_output=$(cat ./test/data/sample_folder_contents01_version_output.txt)

  run get_current_version "$regex" "$(cat ./test/data/sample_folder_contents01.txt)"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected_output" ]
  # [ "$result" -eq 4 ]
}

@test "get_current_version returns expected version for dotted numbers" {
  source assets/common.sh

  export regex="bosh_v(?<version>.*).yml"
  export expected_output=$(cat ./test/data/sample_folder_contents01_v_version_output.txt)

  run get_current_version "$regex" "$(cat ./test/data/sample_folder_contents01.txt)"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected_output" ]
  # [ "$result" -eq 4 ]
}

@test "get_current_version returns expected versions for non-numeric versions" {
  source assets/common.sh

  export regex="artifact-(?<version>.*).zip"
  export expected_output="[
  {
    \"version\": \"v1.0-patch.3\"
  }
]"

  local folderContents="{
    \"uri\" : \"/artifact-v1.0-patch-2.zip\",
    \"folder\" : false
    }, {
    \"uri\" : \"/artifact-v1.0-patch-1.zip\",
    \"folder\" : false
    }, {
    \"uri\" : \"/artifact-v1.0-patch.3.zip\",
    \"folder\" : false
  }"

  folderContents="$(createSampleFolderContents "${folderContents}")"
  run get_current_version "$regex" "$folderContents"

  echo "output: $output"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected_output" ]
}


@test "get_current_version returns expected versions for non-numeric rc versions" {
  source assets/common.sh

  export regex="artifact-file-(?<version>.*).zip"
  export expected_output="[
  {
    \"version\": \"0.0.1-rc.356\"
  }
]"

  local folderContents="{
    \"uri\" : \"/artifact-file-0.0.1-rc.356.zip\",
    \"folder\" : false
    }, {
    \"uri\" : \"/artifact-file-0.0.1-rc.248.zip\",
    \"folder\" : false
    }, {
    \"uri\" : \"/artifact-file-0.0.1-rc.301.zip\",
    \"folder\" : false
  }"

  folderContents="$(createSampleFolderContents "${folderContents}")"
  run get_current_version "$regex" "$folderContents"

  echo "output: $output"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected_output" ]
}

@test "get_all_versions returns expected version" {
  source assets/common.sh

  export regex="myapp-(?<version>.*).txt"
  export expected_output=$(cat ./test/data/sample_folder_contents01_allversions_output.txt)

  run get_all_versions "$regex" "$(cat ./test/data/sample_folder_contents01.txt)"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected_output" ]
  # [ "$result" -eq 4 ]
}

@test "get_files returns expected content" {
  source assets/common.sh

  export regex="myapp-(?<version>.*).txt"
  export expected_output=$(cat ./test/data/sample_folder_contents01_files_output.txt)

  run get_files "$regex" "$(cat ./test/data/sample_folder_contents01.txt)"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected_output" ]
  # [ "$result" -eq 4 ]
}

function createSampleFolderContents() {
  local folderContents="${1}"
  local tempFile=$(mktemp /tmp/tmp.XXXXXXXXXX)
  cat > $tempFile <<EOF
{
  "repo" : "testrepo",
  "path" : "/",
  "created" : "2018-02-09T19:55:45.216Z",
  "lastModified" : "2018-02-09T19:55:45.216Z",
  "lastUpdated" : "2018-02-09T19:55:45.216Z",
  "children" : [
  $folderContents
  ],
  "uri" : "http://192.168.99.100:8081/artifactory/api/storage/testrepo"
}
EOF
  echo "$(cat $tempFile)"
}
