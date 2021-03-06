# encoding: UTF-8

require 'pp'

require_relative '../shared'
require_relative '../../commands/process'
require_relative '../../commands/runners'
require_relative '../../client'

GoodData::CLI.module_eval do

  desc 'Run ruby bricks either locally or remotely deployed on our server'
# arg_name 'show'
  command :run_ruby do |c|

    c.desc 'Directory of the ruby brick'
    c.default_value nil
    c.flag [:d, :dir]

    c.desc 'Log file. If empty STDOUT will be used instead'
    c.default_value nil
    c.flag [:l, :logger]

    c.desc 'Params file path. Inside should be hash of key values'
    c.default_value nil
    c.flag [:params]

    c.desc 'Run on remote machine'
    c.switch [:r, :remote]

    c.desc 'Name of the deployed process'
    c.default_value nil
    c.flag [:n, :name]

    c.action do |global_options, options, args|
      verbose = global_options[:verbose]
      options[:expanded_params] = if options[:params]
                                    MultiJson.load(File.read(options[:params]))
                                  else
                                    {}
                                  end

      opts = options.merge(global_options).merge(:type => 'RUBY')
      GoodData.connect(opts)
      if options[:remote]
        fail 'You have to specify name of the deploy when deploying remotely' if options[:name].nil? || options[:name].empty?
        require_relative '../../commands/process'
        GoodData::Command::Process.run(options[:dir], './main.rb', opts)
      else
        require_relative '../../commands/runners'
        GoodData::Command::Runners.run_ruby_locally(options[:dir], opts)
      end
      puts HighLine.color('Running ruby brick - DONE', HighLine::GREEN) if verbose
    end
  end

end
