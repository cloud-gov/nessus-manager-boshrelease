# BOSH Release for the Nessus Manager

## Usage

Due to licensing, we cannot package the Nessus products. These instructions assume a Tenable subscription.

1. Download the Nessus deb package from [Tenable](https://www.tenable.com/downloads/nessus) and add the Nessus deb package as a blob:

    ```shell
    git clone cloud-gov/cg-nessus-manager-boshrelease
    cd cg-nessus-manager-boshrelease
    mkdir -p blobs/nessus-manager/
    cp ~/Downloads/Nessus-* blobs/nessus-manager/
    bosh add-blob ./blobs/nessus-manager/Nessus-* nessus-manager/Nessus-*
    ```

2. Create and upload a release:

    ```shell
    git add .
    git commit -S -sm "updating nessus manager."
    bosh create release
    bosh upload release
    ```

3. Set deployment manifest:

    ```shell
    bosh deployment manifests/bosh-lite.yml
    ```

4. Deploy:

    ```sh
    bosh -d nessus-manager deploy manifests/bosh-lite.yml
    bosh -d nessus-manager instances
    ```

---

A license key and administrator credentials are required. Note that although a license key is required by this release, it can be an invalid key; A valid key can be entered later with the `nessuscli` command line utility.

For configuration information, see the spec at `jobs/nessus-manager/spec` and example manifest at `manifests/nessus-manager.yml`.

Nessus resides on a persistent disk; size the disk accordingly. After deployment, the web UI is available at https://IP:8834 (with an SSL certificate signed by Nessus Certification Authority.
