workflow "Build R package" {
  on = "push"
  resolves = ["checks"]
}

action "checkout" {
  uses = "actions/checkout@v1"
}

action "deps" {
  uses = "r-lib/ghactions/actions/install-deps@master"
  needs = ["checkout"]
}

action "checks" {
  uses = "r-lib/ghactions/actions/check@master"
  needs = ["deps"]
}
