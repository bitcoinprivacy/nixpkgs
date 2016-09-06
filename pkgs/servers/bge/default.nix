{sbt,stdenv, fetchgit,jdk, makeWrapper}:
 stdenv.mkDerivation {
    name = "bge";

    buildPhase = let
      sbtBootDir = "./.sbt/boot/";
      sbtIvyHome = "/var/tmp/`whoami`/.ivy";
      sbtOpts = "-XX:PermSize=190m -Dsbt.boot.directory=${sbtBootDir} -Dsbt.ivy.home=${sbtIvyHome}";
      in ''
        mkdir -p ${sbtBootDir}
        mkdir -p ${sbtIvyHome}
        sbt ${sbtOpts} assembly publish-local
        cd api
        mkdir -p ${sbtBootDir}
        mkdir -p ${sbtIvyHome}
        sbt ${sbtOpts} assembly
        cd ..
      '';

    installPhase = ''
     mkdir -p $out
     mkdir -p $out/bin/
     cp  ./target/scala-2.11/bge-assembly-3.0.jar $out
     cp bge $out/bin/
     cp  ./api/target/scala-2.11/bgeapi-assembly-1.0.jar $out
     cp api/bgeapi $out/bin/
     wrapProgram $out/bin/bge --suffix LD_LIBRARY_PATH : ${stdenv.cc.cc.lib}/lib                 
    '';

    src = fetchgit {
    url = "git://github.com/bitcoinprivacy/Bitcoin-Graph-Explorer.git";
    rev = "d309d06";
    md5 = "6735bcb2a2d6597e568ad50eb08459a9";
    } ;
    JAVA_HOME = "${jdk}";
    shellHook = ''

    export PS1="BGE > " '';
#    LD_LIBRARY_PATH="${stdenv.cc.cc}/lib64";

    buildInputs = [sbt makeWrapper];
}
