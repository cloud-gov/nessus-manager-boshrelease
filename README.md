# BOSH Release for the nessus manager

## Usage

```
bosh target BOSH_HOST
git clone https://github.com/18F/cg-nessus-manager-boshrelease.git
cd cg-nessus-manager-boshrelease
bosh upload release releases/nessus-manager/nessus-manager-1.yml
```

A license key and administrator credentials are required.  Note, although a license key is required by this release, it can be an invalid key; A valid key can be entered later via the web UI or command line.

See the spec at `jobs/nessus-manager/spec` and example manifest at `manifests/bosh-lite.yml`.

