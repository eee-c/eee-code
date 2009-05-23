task :default => [:test]

task :test => [:app_specs, :helper_specs, :view_specs]

task :app_specs do
  $stderr.puts "\n==\nSinatra app spec"
  system("spec", "./spec/eee_spec.rb")
end

task :helper_specs do
  $stderr.puts "\n==\nHelper specs"
  system("spec", "./spec/eee_helpers_spec.rb")
end

task :view_specs do
  $stderr.puts "\n==\nView specs"
  system("spec ./spec/views/*.haml_spec.rb")
end
