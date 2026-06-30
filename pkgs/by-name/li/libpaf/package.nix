{
  lib,
  stdenv,
  fetchFromGitHub,

  # nativeBuildInputs
  autoreconfHook,
  libtool,

  # buildInputs
  jansson,
  python3,
  readline,
  xcm ? xcm.override { inherit withLTTng; },

  # LTTng
  lttng-ust,
  withLTTng ? false,
}:
stdenv.mkDerivation rec {
  pname = "libpaf";
  version = "1.1.15";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Ericsson";
    repo = "libpaf";
    tag = "v${version}";
    hash = "sha256-qXIP2yonp4l7E+3AmZuJXb3VWjms0VR76g2/n4/WKAM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    libtool
    python3
  ];

  buildInputs = [
    jansson
    readline
    xcm
  ]
  ++ lib.optional withLTTng lttng-ust;

  postPatch = ''
    substituteInPlace python/libpaf.py \
      --replace-fail 'CDLL("libpaf.so.0"' 'CDLL("${placeholder "out"}/lib/libpaf.so.0"'
  '';

  preConfigure = ''
    patchShebangs .
  '';
  configureFlags = lib.optional (!withLTTng) "--disable-lttng";

  enableParallelBuilding = true;

  meta = {
    homepage = "https://github.com/Ericsson/libpaf";
    changelog = "https://github.com/Ericsson/libpaf/releases/tag/v${version}";
    description = "Pathfinder service discovery client library ";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "lpafc";
    maintainers = [
      lib.maintainers.kacper-uminski
    ];
  };
}
