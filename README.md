# BOSH Release for the Nessus Manager

## Usage

These examples use [bosh-lite](https://github.com/cloudfoundry/bosh-lite).

Target bosh and clone the repo
```
bosh target 192.168.50.4
git clone https://github.com/18F/cg-nessus-manager-boshrelease.git
```

Download the Nessus deb package from http://www.tenable.com

Add the Nessus deb package as a blob

```
cd cg-nessus-manager-boshrelease
bosh add blob path/to/Nessus*.deb nessus-manager
```

Create and upload a release
```
bosh create release --force
bosh upload release
```

Set deployment manifest
```
bosh deployment manifests/bosh-lite.yml
```

Deploy
```
bosh deploy
```

--

A license key and administrator credentials are required.  Note that although a license key is required by this release, it can be an invalid key; A valid key can be entered later with the `nessuscli` command line utility.

For configuration information, see the spec at `jobs/nessus-manager/spec` and example manifest at `manifests/bosh-lite.yml`.

Nessus resides on a persistent disk; size the disk accordingly.

After deployment, the web UI is available at https://10.244.18.2:8834 (for a bosh-lite deployment) with an SSL certificate signed by Nessus Certification Authority.

