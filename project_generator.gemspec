# frozen_string_literal: true

require_relative 'lib/project_generator/version'

Gem::Specification.new do |spec|
	spec.name        = 'project_generator'
	spec.version     = ProjectGenerator::VERSION
	spec.authors     = ['Alexander Popov']
	spec.email       = ['alex.wayfer@gmail.com']

	spec.summary     = 'Base for various CLI generation tools'
	spec.description = <<~DESC
		Base for various CLI generation tools.
	DESC
	spec.license = 'MIT'

	github_uri = "https://github.com/AlexWayfer/#{spec.name}"

	spec.homepage = github_uri

	spec.metadata = {
		'rubygems_mfa_required' => 'true',
		'bug_tracker_uri' => "#{github_uri}/issues",
		'changelog_uri' => "#{github_uri}/blob/v#{spec.version}/CHANGELOG.md",
		'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
		'homepage_uri' => spec.homepage,
		'source_code_uri' => github_uri,
		'wiki_uri' => "#{github_uri}/wiki"
	}

	spec.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']

	spec.required_ruby_version = '~> 3.0'

	spec.add_runtime_dependency 'alt_memery', '~> 2.0'
	spec.add_runtime_dependency 'bundler', '~> 2.0'
	spec.add_runtime_dependency 'clamp', '~> 1.3'
	spec.add_runtime_dependency 'gorilla_patch', '~> 5.0'

	spec.add_development_dependency 'pry-byebug', '~> 3.9'

	spec.add_development_dependency 'bundler', '~> 2.0'
	spec.add_development_dependency 'bundler-audit', '~> 0.9.0'

	spec.add_development_dependency 'gem_toys', '~> 0.12.1'
	spec.add_development_dependency 'toys', '~> 0.14.2'

	spec.add_development_dependency 'inifile', '~> 3.0'
	spec.add_development_dependency 'rspec', '~> 3.9'
	spec.add_development_dependency 'simplecov', '~> 0.21.0'
	spec.add_development_dependency 'simplecov-cobertura', '~> 2.1'

	spec.add_development_dependency 'rubocop', '~> 1.40.0'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end
