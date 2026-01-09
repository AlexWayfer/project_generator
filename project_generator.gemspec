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

	spec.add_dependency 'alt_memery', '~> 3.0'
	spec.add_dependency 'bundler', '>= 2.0', '< 5.0'
	spec.add_dependency 'clamp', '~> 1.3'
	spec.add_dependency 'gorilla_patch', '~> 5.0'
end
