# frozen_string_literal: true

require 'gorilla_patch/blank'
require 'gorilla_patch/inflections'
require 'memery'
require 'yaml'

module ProjectGenerator
	## Base CLI command for Project Generator
	class Command < Clamp::Command
		## Private instance methods for processing template files (copying, renaming, rendering)
		module ProcessFiles
			## Class for a single object which should be a scope in render
			class RenderVariables
				include Memery

				using GorillaPatch::Blank
				using GorillaPatch::Inflections

				attr_reader :name, :indentation

				def initialize(name, indentation)
					@name = name
					@indentation = indentation
				end

				## `public :binding` and `send :binding` return caller binding
				## This is from ERB documentation: https://ruby-doc.org/core-2.7.2/Binding.html
				# rubocop:disable Naming/AccessorMethodName
				def get_binding
					binding
				end
				# rubocop:enable Naming/AccessorMethodName

				memoize def path
					name.tr('-', '/')
				end

				memoize def title
					name.split(/[-_]/).map(&:camelize).join(' ')
				end

				memoize def module_name
					path.camelize
				end

				memoize def modules
					module_name.split('::')
				end
			end
		end
	end
end
