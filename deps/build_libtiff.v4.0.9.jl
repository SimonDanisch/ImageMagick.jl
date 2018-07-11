using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libtiff"], :libtiff),
    LibraryProduct(prefix, String["libtiffxx"], :libtiffxx),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/SimonDanisch/LibTIFFBuilder/releases/download/v4.0.9"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/libtiff.v4.0.9.aarch64-linux-gnu.tar.gz", "3ca1f4b33342ae4a3d31ef36cb795f2e84c4824ae9797fb3af6ce71496631296"),
    Linux(:aarch64, :musl) => ("$bin_prefix/libtiff.v4.0.9.aarch64-linux-musl.tar.gz", "4c33b9c470e25e218bb2121192afb84a5da181b31153b5b49f132a33b84f9985"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/libtiff.v4.0.9.arm-linux-gnueabihf.tar.gz", "29d9adc51fcaa76d4587d36c343ae84d277332dccaacee16372a064394e4ecb1"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/libtiff.v4.0.9.arm-linux-musleabihf.tar.gz", "686cebe08046d51fb4d6fffc7cebf3b299f9287709ba1e528760a7a8a6673c8c"),
    Linux(:i686, :glibc) => ("$bin_prefix/libtiff.v4.0.9.i686-linux-gnu.tar.gz", "32655c5a0000d6aeebc0cbb424e495e29a73d2e906e74f17329933f86dd3007a"),
    Linux(:i686, :musl) => ("$bin_prefix/libtiff.v4.0.9.i686-linux-musl.tar.gz", "1e6285161738f6f6237ba2c7f2b976d627075db8a7c4ffe86d663236fab056dc"),
    Windows(:i686) => ("$bin_prefix/libtiff.v4.0.9.i686-w64-mingw32.tar.gz", "83d5126e59e01e15b87a260a00ccdd588d0042307da43ddc2a43f915cafcef73"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/libtiff.v4.0.9.powerpc64le-linux-gnu.tar.gz", "e8044755b4ed0b13c2412a3fc54315c38b77f65127afc21cad13a870295dc253"),
    MacOS(:x86_64) => ("$bin_prefix/libtiff.v4.0.9.x86_64-apple-darwin14.tar.gz", "1879d89146434c8e1af37522a2f4c05cb5ea82c4fbd3121b7db48f0efb1c3a2e"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/libtiff.v4.0.9.x86_64-linux-gnu.tar.gz", "c7b9499a9e2cb4f632009bbeb05a67268c3805229b5b2d33dda4e6710ace45f3"),
    Linux(:x86_64, :musl) => ("$bin_prefix/libtiff.v4.0.9.x86_64-linux-musl.tar.gz", "4248d5735e68e38c70fab5636517e70c3b07b92f2e6aa377227d66359941864c"),
    FreeBSD(:x86_64) => ("$bin_prefix/libtiff.v4.0.9.x86_64-unknown-freebsd11.1.tar.gz", "b472a1487f717fed4e7ff4409c3f65bc611fc26f317900c7e91c0da25a75a79b"),
    Windows(:x86_64) => ("$bin_prefix/libtiff.v4.0.9.x86_64-w64-mingw32.tar.gz", "84c4ca0774b97a16d128650bcb92ad2b7e60cd46d021106b91693189ac378252"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps_tiff.jl"), products)
