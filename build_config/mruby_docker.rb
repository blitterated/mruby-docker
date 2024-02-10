MRuby::Build.new do |conf|
  # load specific toolchain settings
  conf.toolchain

  # include the GEM box
  conf.gembox 'default'

  conf.gem :mgem => 'mruby-regexp-pcre'
  conf.gem :mgem => 'mruby-dir-glob'

  # Turn on `enable_debug` for better debugging
  # conf.enable_debug

  conf.enable_bintest
  conf.enable_test
end
