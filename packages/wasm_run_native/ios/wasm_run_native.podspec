Pod::Spec.new do |s|
  s.name             = 'wasm_run_native'
  s.version          = '0.1.0'
  s.summary          = 'Native WebAssembly runtime library built from Rust'
  s.description      = <<-DESC
Native WebAssembly runtime using wasmtime or wasmi, built from Rust source via Cargokit.
                       DESC
  s.homepage         = 'https://github.com/juancastillo0/wasm_run'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Juan Manuel Castillo' => '42351046+juancastillo0@users.noreply.github.com' }
  s.source           = { :path => '.' }

  s.ios.deployment_target = '12.0'

  # Use cargokit to build the Rust library
  s.script_phase = {
    :name => 'Build Rust library',
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../native wasm_run_native',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony_out'],
  }

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libwasm_run_native.a',
  }

  # Dummy source file to satisfy CocoaPods
  s.source_files = 'Classes/**/*'

  # Declare the Cargokit-built static lib so CocoaPods links its symbols (the
  # frb _wire_*/_share_opaque_* bridge). Do NOT set `static_framework`: that
  # flags this pod as a statically-linked transitive dependency, which app
  # targets using `use_frameworks!` (dynamic) reject ("transitive dependencies
  # that include statically linked binaries"). Without static_framework the pod
  # is a normal dynamic framework that embeds the vendored static lib — the
  # standard pattern for prebuilt-static-lib pods. OTHER_LDFLAGS -force_load
  # above additionally prevents dead-stripping of the bridge symbols.
  s.vendored_libraries = 'libwasm_run_native.a'
end
