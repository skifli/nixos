# Build the same pinned Nix toolchain used by the Oracle-nix Open Terminal image.
ARG OPEN_TERMINAL_BASE_IMAGE
FROM docker.io/nixos/nix:2.34.9 AS nix-tools
ENV NIX_CONFIG="experimental-features = nix-command flakes"
RUN mkdir -p /opt \
    && nix --extra-experimental-features "nix-command flakes" profile install \
      --profile /opt/nix-tools-profile \
      github:NixOS/nixpkgs/f5c082a40f7571c266e74e80ae2e68aadd8a9fc7#nix \
      github:NixOS/nixpkgs/f5c082a40f7571c266e74e80ae2e68aadd8a9fc7#nixfmt-rfc-style \
      github:NixOS/nixpkgs/f5c082a40f7571c266e74e80ae2e68aadd8a9fc7#statix \
      github:NixOS/nixpkgs/f5c082a40f7571c266e74e80ae2e68aadd8a9fc7#deadnix \
    && mkdir -p /opt/nix-tools \
    && cp -aL /opt/nix-tools-profile/. /opt/nix-tools/

FROM ${OPEN_TERMINAL_BASE_IMAGE}
USER root
COPY --from=nix-tools /nix /nix
COPY --from=nix-tools /opt/nix-tools /opt/nix-tools
RUN mkdir -p /etc/nix \
    && printf '%s\n' 'experimental-features = nix-command flakes' 'sandbox = true' > /etc/nix/nix.conf \
    && chown -R user:user /nix /opt/nix-tools
ENV PATH="/opt/nix-tools/bin:${PATH}"
ENV NIX_REMOTE=local
USER user
