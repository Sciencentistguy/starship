with import <nixpkgs> {};

rustPlatform.buildRustPackage rec {
  pname = "starship";
  version = "0.58.0";

  src = fetchFromGitHub {
    owner = "sciencentistguy";
    repo = pname;
    rev = "35f1e442e6691415df6e5c0ec4c86781f491a220";
    sha256 = "sha256-s84fIpCyTF7FrJZGATjIJHt/+aknlhlz1V9s+c4f+Ig=";
  };

  nativeBuildInputs = [ installShellFiles ] ++ lib.optionals stdenv.isLinux [ pkg-config ];

  buildInputs = lib.optionals stdenv.isLinux [ openssl ]
    ++ lib.optionals stdenv.isDarwin [ libiconv Security ];

  postInstall = ''
    for shell in bash fish zsh; do
      STARSHIP_CACHE=$TMPDIR $out/bin/starship completions $shell > starship.$shell
      installShellCompletion starship.$shell
    done
  '';

  cargoSha256 = "sha256-4gBXHf2OEDeOAnx6PbptKTcULTKuV2By2GHKdyIiNxk=";

  preCheck = ''
    HOME=$TMPDIR
  '';

  meta = with lib; {
    description = "A minimal, blazing fast, and extremely customizable prompt for any shell";
    homepage = "https://starship.rs";
    license = licenses.isc;
    maintainers = with maintainers; [ bbigras davidtwco Br1ght0ne Frostman marsam ];
  };
}
