env = java::lang.System.getProperty('imint.env') || 'production'

WARBLER_CONFIG = {"public.root"=>"/", "rack.env" => env }

if $servlet_context.nil?
  ENV['GEM_HOME'] = File.expand_path('../../WEB-INF', __FILE__)
  ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../WEB-INF/Gemfile', __FILE__)
else
  ENV['GEM_HOME'] = $servlet_context.getRealPath('/WEB-INF/gems')
  ENV['BUNDLE_GEMFILE'] ||= $servlet_context.getRealPath('/WEB-INF/Gemfile')
end
ENV['BUNDLE_WITHOUT'] = 'development:test:assets'

ENV['RACK_ENV'] = env

$LOAD_PATH.unshift $servlet_context.getRealPath('/WEB-INF') if $servlet_context

