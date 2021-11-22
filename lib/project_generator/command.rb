# frozen_string_literal: true

require 'bundler'
require 'clamp'
require 'erb'
require 'fileutils'
require 'pathname'
require 'tmpdir'

require_relative 'command/process_files'

## https://github.com/mdub/clamp#allowing-options-after-parameters
Clamp.allow_options_after_parameters = true

module ProjectGenerator
	## Base CLI command for Project Generator
	class Command < Clamp::Command
		include ProcessFiles

		option ['-i', '--indentation'], 'TYPE', 'type of indentation (tabs or spaces)',
			default: 'tabs' do |value|
				## TODO: Add something like `:variants` to Clamp
				unless %w[tabs spaces].include? value
					raise ArgumentError, 'Only `tabs` or `spaces` values acceptable'
				end

				value
			end

		option '--git', :flag, 'use TEMPLATE as GitHub path (clone and generate from it)',
			default: false

		# def execute
		# 	check_target_directory
		#
		# 	refine_template_parameter if git?
		#
		# 	process_files
		#
		# 	initialize_git
		#
		# 	FileUtils.rm_r @git_tmp_dir if git?
		#
		# 	done
		# end

		private

		def check_target_directory
			@directory = File.expand_path name

			signal_usage_error 'the target directory already exists' if Dir.exist? @directory
		end

		def refine_template_parameter
			@git_tmp_dir = Dir.mktmpdir
			`git clone -q https://github.com/#{template}.git #{@git_tmp_dir}`
			self.template = File.join @git_tmp_dir, 'template'
		end

		def initialize_git
			puts 'Initializing git...'

			Dir.chdir name do
				system 'git init'
				system 'git add .'
			end
		end

		def done
			puts
			puts 'Done.'

			puts <<~HELP
				To checkout into a new directory:
					cd #{name}
			HELP
		end
	end
end
