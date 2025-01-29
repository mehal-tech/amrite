# amrite

A custom crun build to enable WasmEdge on Smart Devices on arm64 and X86_64 systems.

See the [docs](https://docs.mehal.tech/amrite) for more information. 

## Support Matrix

We intend to support SUSE, ALMA, Fedora, Ubuntu with both WasmEdge and WASMTime. 
Below is the currently built binaries. The list will be updated as we prioritise support.

For additional OS or WASI runtime support please raise an issue in this repo or mail admin@mehal.tech.   

|OS|Version|WASI Runtimes|Folder|
|---|---|---|---|
|Ubuntu|24.04|WasmEdge|/vendor/ubuntu_24_04|
|Fedora|41|WasmEdge|fedora41|/vendor/fedora_41|

## Usage 

To include the binaries in your image mode container run.

```dockerfile
FROM ghcr.io/mehal-tech/amrite:main as crunbuild 

FROM quay.io/fedora/fedora-bootc:41
COPY --from=crunbuild /vendor/fedora_41/libwasmedge.so.0 /usr/local/lib64/libwasmedge.so.0 
COPY --from=crunbuild /vendor/crun-wasmedge /usr/bin/crun
```