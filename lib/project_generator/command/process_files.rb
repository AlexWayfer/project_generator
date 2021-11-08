# frozen_string_literal: true

require_relative 'process_files/render_variables'

module ProjectGenerator
	## Base CLI command for Project Generator
	class Command < Clamp::Command
		## Private instance methods for processing template files (copying, renaming, rendering)
		module ProcessFiles
			RENAME_FILES_PLACEHOLDERS = {
				name: 'project_name',
				path: 'project_path'
			}.freeze

			private

			def process_files
				copy_files

				begin
					@render_variables = initialize_render_variables

					rename_files

					render_files
				rescue SystemExit => e
					FileUtils.rm_r @directory
					raise e
				end
			end

			def initialize_render_variables
				self.class::ProcessFiles::RenderVariables.new name, indentation
			end

			def copy_files
				puts 'Copying files...'

				FileUtils.cp_r template, @directory

				FileUtils.rm_rf "#{@directory}/.git"
			end

			def rename_files
				puts 'Renaming files...'

				self.class::RENAME_FILES_PLACEHOLDERS.each do |method_name, template_name|
					real_name = @render_variables.public_send(method_name)

					Dir["#{@directory}/**/*#{template_name}*"].each do |file_name|
						new_file_name =
							@directory + file_name.delete_prefix(@directory).gsub(template_name, real_name)

						FileUtils.mkdir_p File.dirname new_file_name

						File.rename file_name, new_file_name
					end
				end
			end

			def render_files
				puts 'Rendering files...'

				Dir.glob("#{@directory}/**/*.erb", File::FNM_DOTMATCH).each do |template_file|
					## Read a template file content and render it
					content =
						ERB.new(File.read(template_file), trim_mode: '-').result(@render_variables.get_binding)

					## Replace tabs with spaces if necessary
					## TODO: Take it out of `.erb` files
					## TODO: Take number of spaces from `.editorconfig` file
					## TODO: Don't convert files refined in `.editorconfig`
					## TODO: Convert spaces to tabs
					content.gsub!(/^\t+/) { |tabs| '  ' * tabs.count("\t") } if indentation == 'spaces'

					## Render variables in file name
					real_pathname = Pathname.new(template_file).sub_ext('')

					## Rename template file
					File.rename template_file, real_pathname

					## Update file content
					File.write real_pathname, content
				end
			end
		end
	end
end
