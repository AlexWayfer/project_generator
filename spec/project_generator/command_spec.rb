# frozen_string_literal: true

require 'gorilla_patch/deep_merge'
require 'inifile'

describe ProjectGenerator::Command do
	using GorillaPatch::DeepMerge

	before do
		stub_const('TestCommand', Class.new(described_class) do
			parameter 'NAME', 'name of a new project'
			parameter 'TEMPLATE', 'template path of a new project'

			def execute
				check_target_directory

				refine_template_parameter if git?

				process_files

				initialize_git

				FileUtils.rm_r @git_tmp_dir if git?

				done
			end
		end)
	end

	describe '.run' do
		subject(:run) do
			TestCommand.run('test_generator', args)
		end

		## I'd like to use `instance_double`, but it doesn't support `and_call_original`
		let(:command_instance) { TestCommand.new('test_generator') }

		before do
			# allow(command_instance).to receive(:run).and_call_original
			allow(TestCommand).to receive(:new).and_return command_instance
		end

		context 'without project name parameter' do
			let(:args) { [] }

			it do
				expect { run }.to raise_error(SystemExit).and output(
					/ERROR: parameter 'NAME': no value provided/
				).to_stderr
			end
		end

		context 'with project name parameter' do
			let(:project_name) { 'foo_bar' }
			let(:args) { [project_name] }

			shared_context 'with supressing regular output' do
				before do
					[
						'Copying files...',
						'Renaming files...',
						'Rendering files...',
						'Initializing git...',
						'Done.',
						"To checkout into a new directory:\n\tcd foo_bar\n"
					].each do |line|
						allow($stdout).to receive(:puts).with(line)
					end
				end
			end

			context 'without template parameter' do
				it do
					expect { run }.to raise_error(SystemExit).and output(
						/ERROR: parameter 'TEMPLATE': no value provided/
					).to_stderr
				end
			end

			context 'with template parameter' do
				let(:args) { [*super(), template] }

				before do
					allow(command_instance).to receive(:system).with('git init')
					allow(command_instance).to receive(:system).with('git add .')
				end

				after do
					FileUtils.rm_r project_name if Dir.exist? project_name
				end

				shared_examples 'correct behavior with template' do
					shared_examples 'common correct files with all data' do
						describe 'files' do
							subject(:file_path) { File.join(Dir.pwd, project_name, self.class.description) }

							before do
								run ## parent subject with generation
							end

							describe 'content' do
								subject(:file_content) { File.read file_path }

								describe 'CHANGELOG.md' do
									let(:expected_lines) do
										[
											'# Changelog',
											'## Unreleased',
											'*   Initial release.'
										]
									end

									it { is_expected.to include_lines expected_lines }
								end

								describe 'foo_bar.gemspec' do
									let(:expected_lines) do
										[
											"require_relative 'lib/#{project_name}/version'",
											"spec.name = '#{project_name}'"
										]
									end

									it { is_expected.to include_lines expected_lines }
								end

								describe '.editorconfig' do
									subject(:ini_file) do
										IniFile.load(File.join(Dir.pwd, project_name, '.editorconfig')).to_h
									end

									context 'with default indentation (tabs)' do
										let(:expected_values) do
											a_hash_including(
												'*' => a_hash_including(
													'indent_style' => 'tab',
													'indent_size' => 2
												)
											)
										end

										let(:not_expected_values) do
											a_hash_including(
												'*' => a_hash_including(
													'indent_style' => 'space'
												)
											)
										end

										it { is_expected.to match(expected_values).and not_match(not_expected_values) }

										describe 'lib/foo_bar/version.rb' do
											subject { file_content }

											it { is_expected.to match(/^\tVERSION = '0.0.0'$/) }
											it { is_expected.not_to match(/^  /) }
										end
									end

									context 'with spaces indentation' do
										let(:args) do
											[*super(), '--indentation=spaces']
										end

										let(:expected_values) do
											a_hash_including(
												'*' => a_hash_including(
													'indent_style' => 'space',
													'indent_size' => 2
												)
											)
										end

										let(:not_expected_values) do
											a_hash_including(
												'*' => a_hash_including(
													'indent_style' => 'tab'
												)
											)
										end

										it { is_expected.to match(expected_values).and not_match(not_expected_values) }

										describe 'lib/foo_bar/version.rb' do
											subject { file_content }

											it { is_expected.to match(/^  VERSION = '0.0.0'$/) }
											it { is_expected.not_to match(/^\t/) }
										end
									end
								end

								describe 'permissions' do
									subject(:file_permissions) { File.stat(file_path).mode }

									describe 'bin/console' do
										let(:expected_permissions) do
											File.stat("#{__dir__}/../support/example_template/bin/console.erb").mode
										end

										it { is_expected.to eq expected_permissions }
									end
								end
							end
						end
					end

					describe 'output' do
						let(:expected_output_start) do
							## There is allowed prompt
							<<~OUTPUT
								Copying files...
								Renaming files...
								Rendering files...
								Initializing git...
							OUTPUT
						end

						let(:expected_output_end) do
							<<~OUTPUT
								Done.
								To checkout into a new directory:
									cd #{project_name}
							OUTPUT
						end

						specify do
							expect { run }.to output(
								a_string_starting_with(expected_output_start)
									.and(ending_with(expected_output_end))
							).to_stdout_from_any_process.and not_output.to_stderr_from_any_process
						end
					end

					describe 'system calls' do
						include_context 'with supressing regular output'

						before do
							run
						end

						specify do
							expect(command_instance).to have_received(:system).with('git init').once
						end
					end

					describe 'files' do
						include_context 'with supressing regular output'

						include_examples 'correct files with all data'
					end

					context 'with incorrect indentation option' do
						let(:args) do
							[*super(), '--indentation=foo']
						end

						let(:expected_stderr) do
							<<~OUTPUT
								ERROR: option '--indentation': Only `tabs` or `spaces` values acceptable

								See: 'test_generator --help'
							OUTPUT
						end

						specify do
							expect { run }.to raise_error(SystemExit).and(
								not_output.to_stdout.and(
									output(expected_stderr).to_stderr
								)
							)
						end
					end
				end

				context 'when this template is local (by default)' do
					let(:template) { "#{__dir__}/../support/example_template" }

					context 'when `RenderVariables` is not redefined' do
						shared_examples 'correct files with all data' do
							include_examples 'common correct files with all data'
						end

						include_examples 'correct behavior with template'
					end

					context 'when `RenderVariables` is redefined' do
						let(:custom_file_name) { "#{template}/custom.rb.erb" }

						before do
							File.write custom_file_name, <<~CONTENT
								describe '<%= version_constant %>' do
								end
							CONTENT
						end

						after do
							File.delete custom_file_name
						end

						context 'when its initialization is not redefined' do
							before do
								stub_const 'TestCommand::ProcessFiles', Module.new

								stub_const(
									'TestCommand::ProcessFiles::RenderVariables',
									Class.new(ProjectGenerator::Command::ProcessFiles::RenderVariables) do
										memoize def version_constant
											"#{module_name}::VERSION"
										end
									end
								)
							end

							shared_examples 'correct files with all data' do
								include_examples 'common correct files with all data'

								describe 'custom file' do
									subject { File.read "#{project_name}/custom.rb" }

									before do
										run
									end

									let(:expected_lines) do
										[
											"describe 'FooBar::VERSION' do"
										]
									end

									it { is_expected.to include_lines expected_lines }
								end
							end

							include_examples 'correct behavior with template'
						end

						context 'when its initialization is redefined' do
							before do
								stub_const('TestCommand::ProcessFiles', Module.new do
									private

									def initialize_render_variables
										self.class::ProcessFiles::RenderVariables.new name, 'over9000', indentation
									end
								end)

								TestCommand.include TestCommand::ProcessFiles

								stub_const(
									'TestCommand::ProcessFiles::RenderVariables',
									Class.new(ProjectGenerator::Command::ProcessFiles::RenderVariables) do
										def initialize(name, version, indentation)
											super(name, indentation)

											@version = version
										end

										memoize def version_constant
											@version
										end
									end
								)
							end

							shared_examples 'correct files with all data' do
								include_examples 'common correct files with all data'

								describe 'custom file' do
									subject { File.read "#{project_name}/custom.rb" }

									before do
										run
									end

									let(:expected_lines) do
										[
											"describe 'over9000' do"
										]
									end

									it { is_expected.to include_lines expected_lines }
								end
							end

							include_examples 'correct behavior with template'
						end
					end
				end

				context 'with `--git` option (for template)' do
					template = 'AlexWayfer/gem_template'

					let(:template) { template }
					let(:args) { [*super(), '--git'] }

					before do
						allow(command_instance).to receive(:`).and_call_original

						allow(command_instance).to receive(:`).with(
							a_string_starting_with("git clone -q https://github.com/#{template}.git")
						) do |command|
							target_directory = command.split.last
							FileUtils.copy_entry(
								"#{__dir__}/../support/example_template",
								## git repositories should have nested `template/`
								"#{target_directory}/template"
							)
						end
					end

					shared_examples 'correct files with all data' do
						include_examples 'common correct files with all data'
					end

					include_examples 'correct behavior with template'
				end
			end
		end
	end
end
