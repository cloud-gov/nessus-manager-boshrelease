# BOSH Release for the Nessus Manager

## Usage

Due to licensing, we cannot package the Nessus products. These instructions assume a Tenable subscription.

## Updating Nessus blob

Download the Nessus deb package from [Tenable](https://www.tenable.com/downloads/nessus) and add the Nessus deb package as a blob:

    ```shell
    git clone cloud-gov/cg-nessus-manager-boshrelease
    cd cg-nessus-manager-boshrelease
    mkdir -p blobs/nessus-manager/
    cp ~/Downloads/Nessus-* blobs/nessus-manager/
    bosh add-blob ./blobs/nessus-manager/Nessus-<version> nessus-manager/Nessus-<version>
    ```

The new blob then needs to be uploaded to the blobstore. For [guidance on that process and further informationa bout managing BOSH releases in general, see the BOSH runbook in the internal-docs](https://github.com/cloud-gov/internal-docs/blob/main/docs/runbooks/BOSH/building-bosh-releases.md)

---

A license key and administrator credentials are required. Note that although a license key is required by this release, it can be an invalid key; A valid key can be entered later with the `nessuscli` command line utility.

For configuration information, see the spec at `jobs/nessus-manager/spec` and example manifest at `manifests/nessus-manager.yml`.

Nessus resides on a persistent disk; size the disk accordingly. After deployment, the web UI is available at https://IP:8834 (with an SSL certificate signed by Nessus Certification Authority.
