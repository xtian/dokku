#!/usr/bin/env bats

load test_helper

setup() {
  [[ -f ${DOKKU_ROOT}/ENV ]] && mv -f ${DOKKU_ROOT}/ENV ${DOKKU_ROOT}/ENV.bak
  sudo -H -u dokku /bin/bash -c "echo 'export global_test=true' > ${DOKKU_ROOT}/ENV"
  create_app
}

teardown() {
  destroy_app
  ls -la ${DOKKU_ROOT}
  if [[ -f ${DOKKU_ROOT}/ENV.bak ]];then
    mv -f ${DOKKU_ROOT}/ENV.bak ${DOKKU_ROOT}/ENV
  fi
}

@test "(config) config:set --global" {
  run ssh dokku@dokku.me config:set --global test_var=true test_var2=\"hello world\"
  echo "output: "$output
  echo "status: "$status
  assert_success
}

@test "(config) config:get --global" {
  run ssh dokku@dokku.me config:set --global test_var=true test_var2=\"hello world\" test_var3=\"with\\nnewline\"
  echo "output: "$output
  echo "status: "$status
  assert_success
  run dokku config:get --global test_var2
  echo "output: "$output
  echo "status: "$status
  assert_output 'hello world'
  run dokku config:get --global test_var3
  echo "output: "$output
  echo "status: "$status
  assert_output 'with\nnewline'
}

@test "(config) config:unset --global" {
  run ssh dokku@dokku.me config:set --global test_var=true test_var2=\"hello world\"
  echo "output: "$output
  echo "status: "$status
  assert_success
  run dokku config:get --global test_var
  echo "output: "$output
  echo "status: "$status
  assert_success
  run dokku config:unset --global test_var
  echo "output: "$output
  echo "status: "$status
  assert_success
  run dokku config:get --global test_var
  echo "output: "$output
  echo "status: "$status
  assert_output ""
}

@test "(config) config:set/get" {
  run ssh dokku@dokku.me config:set $TEST_APP test_var1=true test_var2=\"hello world\"
  echo "output: "$output
  echo "status: "$status
  assert_success

  run bash -c "dokku config:get $TEST_APP test_var1 | grep true"
  echo "output: "$output
  echo "status: "$status
  assert_output "true"
  run bash -c "dokku config:get $TEST_APP test_var2 | grep 'hello world'"
  echo "output: "$output
  echo "status: "$status
  assert_output "hello world"
}

@test "(config) config:set/get (with --app)" {
  run bash -c "dokku --app $TEST_APP config:set test_var1=true test_var2=\"hello world\""
  echo "output: "$output
  echo "status: "$status
  assert_success

  run bash -c "dokku --app $TEST_APP config:get test_var1 | grep true"
  echo "output: "$output
  echo "status: "$status
  assert_output "true"
  run bash -c "dokku --app $TEST_APP config:get test_var2 | grep 'hello world'"
  echo "output: "$output
  echo "status: "$status
  assert_output "hello world"
}

@test "(config) config:unset" {
  run ssh dokku@dokku.me config:set $TEST_APP test_var=true test_var2=\"hello world\" test_var3=\"with\\nnewline\"
  echo "output: "$output
  echo "status: "$status
  assert_success
  run dokku config:get $TEST_APP test_var
  echo "output: "$output
  echo "status: "$status
  assert_output "true"
  run dokku config:unset $TEST_APP test_var
  echo "output: "$output
  echo "status: "$status
  assert_success
  run dokku config:get $TEST_APP test_var
  echo "output: "$output
  echo "status: "$status
  assert_output ""
  run dokku config:get $TEST_APP test_var3
  echo "output: "$output
  echo "status: "$status
  assert_output 'with\nnewline'
  run dokku config:unset $TEST_APP test_var3
  echo "output: "$output
  echo "status: "$status
  assert_success
  run dokku config:get $TEST_APP test_var3
  echo "output: "$output
  echo "status: "$status
  assert_output ""
}

@test "(config) global config (herokuish)" {
  deploy_app
  run bash -c "dokku run $TEST_APP env | egrep '^global_test=true'"
  echo "output: "$output
  echo "status: "$status
  assert_success
}

@test "(config) global config (dockerfile)" {
  deploy_app dockerfile
  run bash -c "dokku run $TEST_APP env | egrep '^global_test=true'"
  echo "output: "$output
  echo "status: "$status
  assert_success
}
