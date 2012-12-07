APP_ROOT = File.dirname(__FILE__)

libdir = File.join(APP_ROOT, 'lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)