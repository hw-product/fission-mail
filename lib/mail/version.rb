# NOTE: This is a stupid loading hack for the the mail gems weirdly
# dumb way of loading in the version. Fixes failures encountered
# within jruby instances
module Mail
  module VERSION
    MAJOR, MINOR, PATCH, BUILD = ['2', '5', '4', nil]
    STRING = '2.5.4'
    def self.version
      STRING
    end
  end
end
