MRuby::Build.new do |conf|
  # load specific toolchain settings
  conf.toolchain

  # include the GEM box
  conf.gembox 'default'

  conf.gem :mgem => 'mruby-regexp-pcre' # mruby-dir-glob requires an implementation of RegExp
  conf.gem :mgem => 'mruby-dir-glob'

  conf.gem :mgem => 'mruby-env'

  conf.gem :mgem => 'mruby-ansi-colors'
  conf.gem :mgem => 'mruby-optparse'
  conf.gem :mgem => 'mruby-catch-throw'
  conf.gem :mgem => 'mruby-curl'        # requires libcurl

  conf.gem :github => "gromnitsky/mruby-fileutils-simple"

  # Turn on `enable_debug` for better debugging
  # conf.enable_debug

  conf.enable_bintest
  conf.enable_test
end
