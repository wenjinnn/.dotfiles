# QMD - on-device hybrid search for markdown files (BM25 + vector + LLM rerank)
# https://github.com/tobi/qmd
#
# npm 路线: npm 包自带预编译 dist/, bin/qmd 是纯 node 脚本 (运行时不需要 bun)。
# - 依赖通过 buildNpmPackage 的离线 store (npmDepsHash) 安装, 沙箱内零网络
# - 跳过 install 脚本 (prebuild 下载在无网络沙箱里会失败), 改为 postInstall 里
#   node-gyp 编译 better-sqlite3 (上游 flake 同款做法)
# - src 用 runCommand 把预生成的 package-lock.json 并进 npm tarball
{ pkgs, lib }:

let
  version = "2.8.3";

  tarball = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@tobilu/qmd/-/qmd-${version}.tgz";
    hash = "sha256-LmCCmROgxkYjSpBc79YQQxZ6E5L9z9GbxU+JCvicoPA=";
  };
in
pkgs.buildNpmPackage {
  pname = "qmd";
  inherit version;

  src = pkgs.runCommand "qmd-src-${version}" { nativeBuildInputs = [ pkgs.jq ]; } ''
    mkdir -p $out
    tar xzf ${tarball} -C $out --strip-components=1
    jq 'del(.devDependencies, .peerDependencies) | .optionalDependencies |= with_entries(select(.key == "sqlite-vec-linux-x64"))' \
      $out/package.json > $out/package.json.tmp
    mv $out/package.json.tmp $out/package.json
    cp ${./package-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-7+lrimCtgFcVVnuLProO0jChTtVdDU+Gn3YxCIXpLds=";

  # dist/ 已在 npm 包里预编译 (src/ 不在包里, 无法重新构建), 跳过 npm run build
  dontNpmBuild = true;

  # 不跑 install 脚本 (better-sqlite3/node-llama-cpp 的 prebuild 需要网络下载)
  npmInstallFlags = [ "--ignore-scripts" ];
  dontNpmInstall = true;

  nativeBuildInputs = [
    pkgs.nodejs
    pkgs.node-gyp
    pkgs.python3 # node-gyp 编译 better-sqlite3 需要
    pkgs.makeWrapper
  ];

  buildInputs = [ pkgs.sqlite ];

  installPhase = ''
    runHook preInstall
    packageOut="$out/lib/node_modules/@tobilu/qmd"
    mkdir -p "$packageOut" "$out/bin"
    cp -r ./* "$packageOut/"
    makeWrapper "$packageOut/bin/qmd" "$out/bin/qmd"
    runHook postInstall
  '';

  postInstall = ''
    # 编译 better-sqlite3 原生绑定 (与上游 flake 相同)
    cd "$out/lib/node_modules/@tobilu/qmd/node_modules/better-sqlite3"
    node-gyp rebuild --release
  '';

  postFixup = ''
    # 运行时 sqlite 库路径 (sqlite-vec 扩展加载用), 镜像上游 wrapper
    wrapProgram "$out/bin/qmd" \
      --set DYLD_LIBRARY_PATH "${pkgs.sqlite.out}/lib" \
      --set LD_LIBRARY_PATH "${pkgs.sqlite.out}/lib${lib.optionalString pkgs.stdenv.hostPlatform.isLinux ":${pkgs.stdenv.cc.libc.out}/lib:${pkgs.stdenv.cc.cc.lib}/lib"}"
  '';

  meta = with lib; {
    description = "On-device search engine for markdown notes, meeting transcripts, and knowledge bases";
    homepage = "https://github.com/tobi/qmd";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
