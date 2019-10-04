# BOSH Release for the Nessus Manager

## Usage

These examples use [bosh-lite](https://github.com/cloudfoundry/bosh-lite).

Target bosh and clone the repo

```sh
bosh -e vbox env
git clone https://github.com/18F/cg-nessus-manager-boshrelease.git
```

For creating the release, either set the blobstore [`config/final.yml` to an s3 bucket](https://bosh.io/docs/release-blobstore/#s3-config) you own, [or if building on your own machine, you could set it to `local`](https://bosh.io/docs/release-blobstore/#local-config). If you're using `local`, your `config/final.yml` may look similar to this:

```yml
---
final_name: nessus-manager
blobstore:
  provider: local
  options:
    blobstore_path: /tmp/test-blobs
```

Download the Nessus deb package from http://www.tenable.com

Add the Nessus deb package as a blob

```sh
cd cg-nessus-manager-boshrelease
bosh -e vbox add-blob path/to/Nessus*.deb nessus-manager
```

Create and upload a release

```sh
bosh -e vbox create-release --force
bosh -e vbox upload-release
```

Deploy using the manifest

```sh
bosh -e vbox -d nessus-manager manifests/bosh-lite.yml
```

---

A license key and administrator credentials are required.  Note that although a license key is required by this release, it can be an invalid key; A valid key can be entered later with the `nessuscli` command line utility.

For configuration information, see the spec at `jobs/nessus-manager/spec` and example manifest at `manifests/bosh-lite.yml`.

Nessus resides on a persistent disk; size the disk accordingly.

After deployment, the web UI is available at https://10.244.18.2:8834 (for a `bosh-lite` deployment) with an SSL certificate signed by Nessus Certification Authority.
