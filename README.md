# BOSH Release for the Nessus Manager

## Usage

```
bosh target BOSH_HOST
git clone https://github.com/18F/cg-nessus-manager-boshrelease.git
cd cg-nessus-manager-boshrelease
bosh upload release releases/nessus-manager/nessus-manager-1.yml
```

A license key and administrator credentials are required.  Note that although a license key is required by this release, it can be an invalid key; A valid key can be entered later with the `nessuscli` command line utility.

For configuration information, see the spec at `jobs/nessus-manager/spec` and example manifest at `manifests/bosh-lite.yml`.

Nessus resides on a persistent disk; size the disk accordingly.

After deployment, the web UI is available at https://IP_ADDRESS_IN_MANIFEST:8834 with an SSL certificate signed by Nessus Certification Authority.

