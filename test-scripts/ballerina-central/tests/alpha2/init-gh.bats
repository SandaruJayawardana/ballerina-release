#!./test-libs/bats/bin/bats
# ---------------------------------------------------------------------------
#  Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "Create package '$PACKAGE_NAME:$VERSION' from ALPHA2." {
  run $ALPHA2/bin/bal new $PACKAGE_NAME
  assert_output "Created new Ballerina package '$PACKAGE_NAME' at $PACKAGE_NAME."
  [ "$status" -eq 0 ]
  mv $PACKAGE_NAME "$PACKAGE_NAME-$VERSION"
  local current_user=$(whoami);
  cd "$PACKAGE_NAME-$VERSION"
  sed -i'.original' -e "s/$current_user/$TEST_ORGANIZATION/g" "Ballerina.toml"
  sed -i'.original' -e "s/0.1.0/$VERSION/g" "Ballerina.toml"
  if [ "$REMOVE_STD_LIBS" == "true" ] || [ "$BALLERINA_DEV_CENTRAL" == "true" ] || [ "$BALLERINA_STAGE_CENTRAL" == "true" ]
  then
    sed -i'.original' -e "s/import ballerina\/io;/ /g" "main.bal"
    sed -i'.original' -e 's/io:println("Hello World!");/ /g' "main.bal"
  fi
  rm "Ballerina.toml.original"
  echo '# Sample github package' > "Package.md"
  cd -
}

@test "Build package '$PACKAGE_NAME:$VERSION' from ALPHA2" {
  cd "$PACKAGE_NAME-$VERSION"
  run $ALPHA2/bin/bal build
  assert_line --partial "target/bala/$TEST_ORGANIZATION-$PACKAGE_NAME-any-$VERSION.bala"
  [ "$status" -eq 0 ]
  cd -
}
