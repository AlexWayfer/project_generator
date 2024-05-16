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

				Dir.glob("#{@directory}/**/*", File::FNM_DOTMATCH).each do |file_path|
					next unless File.file? file_path

					render_file file_path
				end
			end

			def render_file(file_path)
				## Read file content
				content = File.read file_path

				pathname = Pathname.new file_path

				if pathname.extname == '.erb'
					## Read a template file content and render it
					content = ERB.new(content, trim_mode: '-').result(@render_variables.get_binding)

					## Remove old template file
					File.delete file_path

					## Remove `.erb` ext from file name
					file_path = pathname.sub_ext('')
				end

				## Replace tabs with spaces if necessary
				## TODO: Take number of spaces from `.editorconfig` file
				## TODO: Don't convert files refined in `.editorconfig`
				## TODO: Convert spaces to tabs
				content.gsub!(/^\t+/) { |tabs| '  ' * tabs.count("\t") } if indentation == 'spaces'

				## Update file content
				File.write file_path, content
			end
		end
	end
end
