{
  lib,
  stdenv,
  fetchFromGitHub,

  # nativeBuildInputs
  autoreconfHook,
  libtool,

  # C-ares
  c-ares,
  withC-ares ? true,

  # Controllers
  withCtl ? true,

  # LTTng
  lttng-ust,
  withLTTng ? true,

  # Python
  python3,
  withPython ? false,

  # Tools
  libevent,
  withTools ? true,

  # TLS
  openssl,
  withTLS ? true,
}:
let
  python = python3.withPackages (python-pkgs: [
    python-pkgs.cryptography
  ]);
in

stdenv.mkDerivation rec {
  pname = "xcm";
  version = "1.12.3";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Ericsson";
    repo = "xcm";
    tag = "v${version}";
    hash = "sha256-U53FSxdLx6CMT6SpdIqSDfZzfa6a7/Vh7FdwEkkb2B4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    libtool
  ]
  ++ lib.optional withPython python;

  buildInputs =
    lib.optional withC-ares c-ares
    ++ lib.optional withTools libevent
    ++ lib.optional withLTTng lttng-ust
    ++ lib.optional withPython python
    ++ lib.optional withTLS openssl;

  postPatch = ''
    substituteInPlace python/xcm.py \
      --replace-fail 'CDLL("libxcm.so.0"' 'CDLL("${placeholder "out"}/lib/libxcm.so.0"'
  '';

  configureFlags =
    lib.optional (!withC-ares) "--disable-cares"
    ++ lib.optional (!withCtl) "--disable-ctl"
    ++ lib.optional (!withLTTng) "--disable-lttng"
    ++ lib.optional (!withPython) "--disable-python"
    ++ lib.optional (!withTools) "--disable-xcm-tool"
    ++ lib.optional (!withTLS) "--disable-tls";

  enableParallelBuilding = true;

  meta = {
    homepage = "https://github.com/Ericsson/xcm";
    changelog = "https://github.com/Ericsson/xcm/releases/tag/v${version}";
    description = "The Extensible Connection-oriented Messaging (XCM) library.";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "xcm";
    maintainers = [
      lib.maintainers.kacper-uminski
    ];
  };
}
